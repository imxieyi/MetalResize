# MetalResize
This is a fast image-resizing framework written in [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders). It supports images with RGBA channels.

## Interpolation
 - [Nearest-neighbor](https://en.wikipedia.org/wiki/Nearest-neighbor_interpolation)
 - [Bilinear](https://en.wikipedia.org/wiki/Bilinear_interpolation)
 - [Bicubic](https://en.wikipedia.org/wiki/Bicubic_interpolation)
 
## Limitations
Both input and output image size should not be larger than `Maximum 2D texture width and height` (typically 8192 or 16384). Memory usage should be less than `Maximum buffer length` (typically 256MB). For details please refer to [Metal Feature Set Tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf).

## Demo
This image is scaled to 8x in all methods.
### Nearest-neighbor
![](screenshots/nearest.png)

### Bilinear
![](screenshots/bilinear.png)

### Bicubic
![](screenshots/bicubic.png)

Image source: [https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62665989](https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62665989)
