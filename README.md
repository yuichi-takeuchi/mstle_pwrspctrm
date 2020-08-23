# mstle_pwrspctrm
 Calculate intervention outcome-resolved power spectrum analysis of 30 ch LFP data

## Getting Started

### Prerequisites
- [MATLAB](https://www.mathworks.com/products/matlab.html)
- [MatlabUtils](https://github.com/yuichi-takeuchi/MatlabUtils)
- [chronux toolbox](http://chronux.org/)

The codes have been tested with MATLAB ver 9.5 (R2018b) with the following toolboxes:
- Curve Fitting Toolbox
- Data Acquisition Toolbox
- Image Acquisition Toolbox
- Image Processing Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- Wavelet Toolbox

### Installing
1. Install MATLAB
2. Clone MatlabUtils in the \code\lib folder as a submodule.
3. Place chronux toolbox in the \code\helper folder.

### How to use
1. dat file should be located in the \data folder
2. Launch \code\main_LTR1_* files
3. Launch \code\main_calculation file
4. Results will be in the \results folder

## Versioning
We use [SemVer](http://semver.org/) for versioning.

## Authors
- **Yuichi Takeuchi, Ph.D.** - *Initial work* - [GitHub](https://github.com/yuichi-takeuchi)
- **Qun Li, Ph.D.** - *Initial work* - [GitHub](https://github.com/liqun2017)

## License
This project is licensed under the MIT License.

## Acknowledgments
- [Berényi lab](http://www.berenyilab.com/)
- [chronux.org](http://chronux.org/)

## References
- Bokil, H., Andrews, P., Kulkarni, J., Mehta, S., Mitra, P. (2010). Chronux: a platform for analyzing neural signals. Journal of neuroscience methods  192(1), 146-51. https://dx.doi.org/10.1016/j.jneumeth.2010.06.020
