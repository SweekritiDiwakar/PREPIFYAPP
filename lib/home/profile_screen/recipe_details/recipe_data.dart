import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';

class RecipeData {
  static final Map<String, Map<String, dynamic>> allRecipes = {
    "Butter Chicken and Naan": {
      "name": "Butter Chicken and Naan",
      "image": "assets/images/butternaan.jpeg",
      "duration": "1.5 hours",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          sectionTitle: "Butter Naan",
          ingredients: [
            "2 cups all-purpose flour",
            "1/2 tsp baking powder",
            "1/2 tsp baking soda",
            "1/2 cup curd (yogurt)",
            "2 tbsp oil",
            "Salt (as needed)",
            "Butter (for brushing)"
          ],
          steps: [
            "Mix flour, baking powder, soda, salt, curd, and oil.",
            "Add little water -> knead into a soft dough.",
            "Cover and rest for 1 hour.",
            "Roll into oval shapes and cook on a hot pan (no oil).",
            "Flip, then brush with butter."
          ],
        ),
        RecipeSection(
          sectionTitle: "Butter Chicken",
          ingredients: [
            "500g boneless chicken",
            "2 tbsp butter",
            "1 onion (finely chopped)",
            "2 tomatoes (blended)",
            "1 tbsp ginger-garlic paste",
            "1 tsp chili powder",
            "1/4 tsp turmeric",
            "1 tsp garam masala",
            "1/2 cup cream",
            "2 tbsp yogurt",
            "Salt (as needed)",
            "Fresh coriander (for garnish)"
          ],
          steps: [
            "Marinate chicken with yogurt, chili, turmeric, salt, and half ginger-garlic paste (30 mins).",
            "Cook chicken in butter till golden, then remove.",
            "In same pan, sauté onion -> add tomato puree + remaining paste.",
            "Add spices and salt -> mix well.",
            "Add chicken + cream -> simmer 5-7 mins.",
            "Finish with butter and coriander."
          ],
        ),
        RecipeSection(
          sectionTitle: "Rice",
          ingredients: [
            "1 cup basmati rice",
            "2 cups water",
            "1 tsp ghee or oil",
            "Salt (to taste)"
          ],
          steps: [
            "Rinse rice till clear.",
            "Add rice, water, salt, and ghee to pot.",
            "Boil -> simmer on low for 10-12 mins.",
            "Fluff with fork."
          ],
        ),
      ]
    },
    "Butter naan and chicken": { // Duplicate for naming matching
      "name": "Butter naan and chicken",
      "image": "assets/images/butternaan.jpeg",
      "duration": "1.5 hours",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          sectionTitle: "Butter Naan",
          ingredients: ["2 cups all-purpose flour", "1/2 tsp baking powder", "1/2 tsp baking soda", "1/2 cup curd (yogurt)", "2 tbsp oil"],
          steps: ["Mix dry ingredients.", "Knead with curd and water.", "Rest, roll, and cook on pan.", "Brush with butter."],
        ),
        RecipeSection(
          sectionTitle: "Butter Chicken",
          ingredients: ["500g chicken", "2 tbsp butter", "1 onion", "Tomato puree", "Ginger-garlic paste", "Cream"],
          steps: ["Marinate and cook chicken.", "Prepare gravy with butter, onion, and tomato puree.", "Add spices, chicken, and cream.", "Simmer and serve."],
        ),
      ]
    },
    "Chocolate Muffin": {
      "name": "Chocolate Muffin",
      "image": "assets/images/muffin.jpeg",
      "duration": "45 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: [
            "1.5 cups all-purpose flour",
            "1 cup sugar",
            "1/2 cup cocoa powder",
            "1 tsp baking soda",
            "1/2 tsp salt",
            "1 cup milk",
            "1/2 cup vegetable oil",
            "1 tsp vanilla extract",
            "1 cup chocolate chips"
          ],
          steps: [
            "Preheat oven to 375°F (190°C).",
            "Whisk dry ingredients.",
            "Mix wet ingredients and combine.",
            "Fold in chips, fill tin, and bake for 20 mins."
          ],
        ),
      ]
    },
    "Chocolate Muffins": { // Plural matching
       "name": "Chocolate Muffins",
      "image": "assets/images/muffin.jpeg",
      "duration": "45 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["1.5 cups flour", "1 cup sugar", "1/2 cup cocoa", "1 cup milk", "Chocolate chips"],
          steps: ["Mix dry and wet ingredients.", "Add chocolate chips.", "Bake at 190°C for 20 mins."],
        ),
      ]
    },
    "Chocolate chip cookies": { // Search screen matching
       "name": "Chocolate chip cookies",
      "image": "assets/images/muffin.jpeg",
      "duration": "30 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["1 cup butter", "1 cup sugar", "2 eggs", "2 cups flour", "2 cups chocolate chips"],
          steps: ["Cream butter and sugar.", "Add eggs and vanilla.", "Mix in dry ingredients and chips.", "Bake at 350°F for 10 mins."],
        ),
      ]
    },
    "Spicy Tomato Pasta": {
      "name": "Spicy Tomato Pasta",
      "image": "assets/images/Spicy Tomato Pasta.jpg",
      "duration": "30 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["250g pasta", "2 tbsp olive oil", "3 cloves garlic", "1 can tomatoes", "Chili flakes"],
          steps: ["Boil pasta.", "Sauté garlic and chili.", "Add tomatoes and simmer.", "Toss with pasta."],
        ),
      ]
    },
    "Kala Chana Chaat": {
      "name": "Kala Chana Chaat",
      "image": "assets/images/Kala Chana Chaat (Black Chickpea Salad).jpg",
      "duration": "20 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["2 cups black chickpeas", "1 onion", "1 tomato", "Chaat masala", "Lemon juice"],
          steps: ["Combine chickpeas, onion, and tomato.", "Add spices and lemon juice.", "Mix well and garnish."],
        ),
      ]
    },
    "Garlic bread": {
      "name": "Garlic bread",
      "image": "assets/images/Garlicbread.jpeg",
      "duration": "15 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Baguette", "4 tbsp butter", "3 cloves garlic", "Parsley"],
          steps: ["Mix butter, garlic, and parsley.", "Spread on bread slices.", "Bake at 400°F till golden."],
        ),
      ]
    },
    "Garlic Bread": { // Case matching
      "name": "Garlic Bread",
      "image": "assets/images/Garlicbread.jpeg",
      "duration": "15 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Baguette", "4 tbsp butter", "3 cloves garlic", "Parsley"],
          steps: ["Mix butter, garlic, and parsley.", "Spread on bread slices.", "Bake till golden."],
        ),
      ]
    },
    "Cajun Sausage Skillet": {
      "name": "Cajun Sausage Skillet",
      "image": "assets/images/Cajun Sausage and Rice Skillet (One-Pan Dinner in 30 minutes!).jpg",
      "duration": "30 mins",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          ingredients: ["1 lb sausage", "1 cup rice", "Onion", "Bell pepper", "Cajun seasoning"],
          steps: ["Brown sausage.", "Sauté veggies.", "Add rice and seasoning.", "Cook until rice is tender."],
        ),
      ]
    },
    "Zucchini Slices": {
      "name": "Zucchini Slices",
      "image": "assets/images/Air Fryer Parmesan Crusted Zucchini Slices are delicious! - Wilingga Recipes.jpg",
      "duration": "20 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["2 zucchinis", "1/2 cup Parmesan", "1/2 cup breadcrumbs"],
          steps: ["Slice zucchini.", "Coat in cheese and breadcrumbs.", "Air fry till crispy."],
        ),
      ]
    },
    "Chicken Burrito": {
      "name": "Chicken Burrito",
      "image": "assets/images/Easy Chipotle Ranch Grilled Chicken Burrito.jpg",
      "duration": "25 mins",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          ingredients: ["Tortillas", "Grilled chicken", "Beans", "Rice", "Cheese"],
          steps: ["Warm tortillas.", "Fill with ingredients.", "Roll and toast."],
        ),
      ]
    },
    "Egg toast": {
      "name": "Egg toast",
      "image": "assets/images/download (1).jpg",
      "duration": "20 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["2 slices bread", "2 eggs", "Butter", "Salt and pepper"],
          steps: ["Butter the bread.", "Fry or scramble eggs.", "Place eggs on toast.", "Season and serve."],
        ),
      ]
    },
    "Pancakes": {
      "name": "Pancakes",
      "image": "assets/images/Panckaes.jpg",
      "duration": "15 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["1 cup flour", "1 cup milk", "1 egg", "2 tbsp sugar", "1 tsp baking powder"],
          steps: ["Whisk ingredients.", "Pour onto hot griddle.", "Flip when bubbles form.", "Serve with syrup."],
        ),
      ]
    },
    "Overnight oats": {
      "name": "Overnight oats",
      "image": "assets/images/download (2).jpg",
      "duration": "10 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["1/2 cup rolled oats", "1/2 cup milk", "Chia seeds", "Honey", "Fruit"],
          steps: ["Combine oats and milk in a jar.", "Add seeds and sweetener.", "Refrigerate overnight.", "Top with fruit."],
        ),
      ]
    },
    "Chickpeas": {
      "name": "Chickpeas",
      "image": "assets/images/Kala Chana Chaat (Black Chickpea Salad).jpg",
      "duration": "22 mins",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          ingredients: ["2 cups chickpeas", "Onion", "Tomato", "Chaat masala"],
          steps: ["Boil chickpeas.", "Mix with chopped onion and tomato.", "Add spices and toss."],
        ),
      ]
    },
    "Chicken Wrap": {
      "name": "Chicken Wrap",
      "image": "assets/images/Easy Chipotle Ranch Grilled Chicken Burrito.jpg",
      "duration": "1.5 hours",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          ingredients: ["Tortillas", "Chicken", "Lettuce", "Tomato", "Sauce"],
          steps: ["Cook chicken.", "Prepare veggies.", "Wrap ingredients in tortilla.", "Serve."],
        ),
      ]
    },
    "Pasta": {
      "name": "Pasta",
      "image": "assets/images/Spicy Tomato Pasta.jpg",
      "duration": "1 hour",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Pasta", "Tomato sauce", "Garlic", "Oil"],
          steps: ["Boil pasta.", "Sauté garlic.", "Mix with sauce and pasta.", "Serve."],
        ),
      ]
    },
    "Daal bhat": {
      "name": "Daal bhat",
      "image": "assets/images/Red Lentil Curry (vegan) _ Masoor Dal.jpg",
      "duration": "30 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Lentils", "Rice", "Spices", "Ghee"],
          steps: ["Cook lentils with spices.", "Boil rice.", "Serve hot with ghee."],
        ),
      ]
    },
    "Sausage and rice skillet": {
      "name": "Sausage and rice skillet",
      "image": "assets/images/Cajun Sausage and Rice Skillet (One-Pan Dinner in 30 minutes!).jpg",
      "duration": "30 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Sausage", "Rice", "Cajun seasoning", "Veggies"],
          steps: ["Brown sausage.", "Sauté veggies.", "Add rice and seasoning.", "Cook until tender."],
        ),
      ]
    },
    "Brownies": {
      "name": "Brownies",
      "image": "assets/images/download (3).jpg",
      "duration": "45 mins",
      "difficulty": "Medium",
      "sections": [
        RecipeSection(
          ingredients: ["Cocoa powder", "Flour", "Sugar", "Butter", "Eggs"],
          steps: ["Melt butter and sugar.", "Add eggs and cocoa.", "Mix in flour.", "Bake at 350°F for 25 mins."],
        ),
      ]
    },
    "Chocolate muffins": {
      "name": "Chocolate muffins",
      "image": "assets/images/muffin.jpeg",
      "duration": "30 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Flour", "Cocoa", "Sugar", "Milk", "Choco chips"],
          steps: ["Mix wet and dry.", "Add chips.", "Bake at 375°F for 20 mins."],
        ),
      ]
    },
    "Chocolate covered strawberry": {
      "name": "Chocolate covered strawberry",
      "image": "assets/images/download (4).jpeg",
      "duration": "10 mins",
      "difficulty": "Easy",
      "sections": [
        RecipeSection(
          ingredients: ["Strawberries", "Chocolate chips", "Coconut oil (optional)"],
          steps: ["Melt chocolate.", "Dip strawberries.", "Chill until set."],
        ),
      ]
    },
  };
}
