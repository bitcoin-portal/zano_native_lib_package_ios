# zano_native_lib_packages

## How to generate xcframeworks for your ios app
### Prerequisites
1. go to https://github.com/hyle-team/zano_native_lib_package_ios and clone the repo
2. Move the xcframeworks in https://github.com/hyle-team/zano_native_lib_package_ios/tree/main/Dependencies to your ios app project. 
(You can also generate the dependencies from https://github.com/hyle-team/zano_native_lib_package_)

* this step can be omitted and we can track the dependencies instead if the size  of the dependencies is smaller than 100MB or we pay for github lfs.

### Generate xcframeworks for your ios app (Swift)
1. Run `./script.sh`. this generates `zano_ios.xcframework` in the project directory
2. Move zano_ios.xcframework to your ios app project


### Set up embedded binaries
1. Go to your project settings
2. Select general
3. Change the option for the embedded binaries to `Embed & Sign` (Other wise app carashes for the production build)