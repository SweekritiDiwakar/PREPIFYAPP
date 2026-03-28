const admin = require("firebase-admin");
const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");

admin.initializeApp();
const db = admin.firestore();

async function fetchMemberTokens(householdId) {
  const householdSnap = await db.collection("households").doc(householdId).get();
  if (!householdSnap.exists) return [];

  const members = householdSnap.get("members") || [];
  if (!Array.isArray(members) || members.length === 0) return [];

  const tokenSet = new Set();
  await Promise.all(
    members.map(async (uid) => {
      const userSnap = await db.collection("users").doc(uid).get();
      const token = userSnap.get("fcmToken");
      if (token && typeof token === "string") tokenSet.add(token);
    }),
  );

  return [...tokenSet];
}

async function sendToHousehold({householdId, title, body, type, data = {}}) {
  const tokens = await fetchMemberTokens(householdId);
  if (tokens.length === 0) return;

  const message = {
    tokens,
    notification: {title, body},
    data: {
      householdId,
      type,
      ...Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)]),
      ),
    },
    android: {
      priority: "high",
      notification: {
        channelId: "prepify_household_channel",
      },
    },
  };

  await admin.messaging().sendEachForMulticast(message);
}

// Generic event fan-out. Triggered by client-created household events.
exports.onHouseholdEventCreated = onDocumentCreated(
  "household_events/{eventId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const householdId = data.householdId;
    if (!householdId) return;

    await sendToHousehold({
      householdId,
      title: data.title || "Prepify update",
      body: data.body || "You have a new household update.",
      type: data.type || "general",
      data: {eventId: snap.id},
    });
  },
);

// Backup trigger: new grocery item -> notification
exports.onGroceryItemCreated = onDocumentCreated(
  "grocery_lists/{listId}/items/{itemId}",
  async (event) => {
    const itemSnap = event.data;
    if (!itemSnap) return;

    const listId = event.params.listId;
    const listSnap = await db.collection("grocery_lists").doc(listId).get();
    if (!listSnap.exists) return;

    const householdId = listSnap.get("householdId");
    if (!householdId) return;

    const itemName = itemSnap.get("itemName") || "Item";
    await sendToHousehold({
      householdId,
      title: "New grocery item",
      body: `${itemName} was added to your list.`,
      type: "grocery_item_added",
      data: {listId, itemId: itemSnap.id},
    });
  },
);

// Backup trigger: item marked purchased -> notification
exports.onGroceryItemUpdated = onDocumentUpdated(
  "grocery_lists/{listId}/items/{itemId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before || !after) return;
    if (before.isChecked === true || after.isChecked !== true) return;

    const listId = event.params.listId;
    const listSnap = await db.collection("grocery_lists").doc(listId).get();
    if (!listSnap.exists) return;

    const householdId = listSnap.get("householdId");
    if (!householdId) return;

    const itemName = after.itemName || "Item";
    await sendToHousehold({
      householdId,
      title: "Item purchased",
      body: `${itemName} was marked as purchased.`,
      type: "grocery_item_purchased",
      data: {listId, itemId: event.params.itemId},
    });
  },
);

// Backup trigger: new household member joined -> notification
exports.onHouseholdMembersUpdated = onDocumentUpdated(
  "households/{householdId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before || !after) return;

    const beforeMembers = Array.isArray(before.members) ? before.members : [];
    const afterMembers = Array.isArray(after.members) ? after.members : [];
    if (afterMembers.length <= beforeMembers.length) return;

    const householdId = event.params.householdId;
    await sendToHousehold({
      householdId,
      title: "New household member",
      body: "A new user joined your household.",
      type: "household_member_joined",
      data: {householdId},
    });
  },
);
