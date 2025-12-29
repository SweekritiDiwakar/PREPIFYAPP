import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Current page index
  var currentPageIndex = 0.obs;
  
  // Total number of onboarding pages
  final int pageCount = 3;
  
  // Update current page index
  void updatePageIndex(int index) {
    currentPageIndex.value = index;
  }
  
  // Navigate to next page
  void next() {
    if (currentPageIndex.value < pageCount - 1) {
      currentPageIndex.value++;
    }
  }
  
  // Navigate to previous page
  void previous() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
    }
  }
  
  // Check if this is the first page
  bool get isFirstPage => currentPageIndex.value == 0;
  
  // Check if this is the last page
  bool get isLastPage => currentPageIndex.value == pageCount - 1;
}