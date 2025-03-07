# zano_native_lib_packages  

A Swift wrapper around the Zano C++ library. Use it to create iOS apps that interact with the Zano wallet.  

## How to Generate XCFrameworks for Your iOS App  

### Prerequisites  

1. Clone the repository:  
   ```sh
   git clone https://github.com/hyle-team/zano_native_lib_package_ios
   ```
2. Move the XCFrameworks from the [`Dependencies`](https://github.com/hyle-team/zano_native_lib_package_ios/tree/main/Dependencies) folder into your iOS app project.  
   - Alternatively, you can generate the dependencies from [`zano_native_lib_package_`](https://github.com/hyle-team/zano_native_lib_package_).  

   **Note:** This step can be skipped if the dependencies are under 100MB, or if we use GitHub LFS for larger files.  

### Generating XCFrameworks for Your iOS App (Swift)  

1. Run the script:  
   ```sh
   ./script.sh
   ```
   This will generate `zano_ios.xcframework` in the project directory.  
2. Move `zano_ios.xcframework` to your iOS app project.  

### Setting Up Embedded Binaries  

1. Open your project settings in Xcode.  
2. Go to the **General** tab.  
3. Under **Embedded Binaries**, set `zano_ios.xcframework` to **Embed & Sign**.  
   - This prevents crashes in production builds.  
