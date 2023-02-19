#include <opencv2/opencv.hpp>

int main(int argc, char *argv[]) {
  const auto size = cv::Size{20, 20};
  const auto image = cv::Mat{size, CV_8UC3, cv::Scalar::all(0)};
  image(cv::Rect{0, 0, size.width / 2, size.height}) = cv::Scalar{255, 0, 0};
  image(cv::Rect{size.width / 2, 0, size.width / 2, size.height}) =
      cv::Scalar{0, 0, 255};

  return 0;
}
