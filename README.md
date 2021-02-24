# PicSplash

<p>
  <img src="https://img.shields.io/badge/iOS-13.0+-blue.svg" />
  <img src="https://img.shields.io/badge/Swift-5.0-brightgreen.svg" />
</p>


<img src="PicSplash.gif" height="640">


## Description

PicSplash is my custom clone of the old version of the Unsplash app. The app displays high quality images, rendered at their 
original aspect ratios, and allows the user to search through these images, all using the Unsplash API. PicSplash contains many 
of the notable features of its predecessor including a parallax image that adjusts its size as a user scrolls, as well as a group-
centered horizontal list of Collections. The app makes heavy use of background fetches and asynchronous Operations to provide a 
smooth user experience while consuming minimal battery life and system resources while downloading large images.

PicSplash uses a custom app icon and custom assets - all created in the Sketch project that is within in this repo!


## Features

- Lazily loads images using custom Operations/OperationQueues
- Prefetching/Downsampling images via Apple guidelines for system/device efficacy
- Custom view controller transitions and animations to enhance user experience
- Provides [blurred image produced from unique hash](https://github.com/woltapp/blurhash) while image loads in background
- Light/Dark mode compatible


## Install

1. Install [git lfs](https://www.atlassian.com/git/tutorials/git-lfs#installing-git-lfs)
2. Create an [Unsplash developer account](https://unsplash.com/developers) to receive a free API key
3. Clone the repo and open the project
4. Assign a development team under "Signing & Capabilities" section under project target
5. Create a new Swift file called `Secrets` and store the file under the `Helpers` directory within the XCode project repo
6. Copy and paste this code into the new `Secrets` file and insert your API key

```
final class Secrets {
	static let API_KEY: String = " --INSERT YOUR API KEY HERE-- "
}
```

7. Build and run the app! There's no third-party packages or pods!


## Disclaimer

- The app is currently limited to 50 network requests per hour per API key
- The app uses 3 network requests upon each run and one network request per each user search
- Image downloads do not count against the 50 network request limit


## App Icon

<img src="PicSplash.png" height="320">


## Feedback

Any and all feedback is welcome - including pull requests.
