# LEGO Assembly Guide with Augmented Reality

Welcome to the Final Year Project 2022-2023 developed by Tianxiang Song. Please view the [dissertation](./Dissertation.pdf) for additional information. Specifically, see Appendix A for **installation** and **usage**.

## Project File Structure

In project root directory, the folder hierarchy is as follows:

-   `LEGOAssemblyGuide` - main files for the application
    -   `Assets` - including UI Markup Language, AR reference image, digital LEGO model, CNN model and app icons
    -   `Data` - dataset for assembly state classification, including source code for CNN training and testing (`train.ipynb`)
    -   `Sources` - source code of the main application
-   `LEGOAssemblyGuideDocs` - files for HTML documentation
-   `LEGOAssemblyGuideIntegrationTests` - code for integration testing
-   `LEGOAssemblyGuideUITests` - code for UI testing
-   `LEGOAssemblyGuideUnitTests` - code for unit testing

In addition, you can find two supplementary PDF files:

-   `AssemblyBaseA4` - print it in A4 paper as assembly base with image marker
-   `AssemblyGuideBook` - official assembly guide for LEGO 21034

## Software Documentation

There are three ways to view the software documentation:

1.  Open `LEGOAssemblyGuide.doccarchive` in project root with Xcode
2.  Visit [online version](https://stx666michael.github.io/) in a web browser
3.  Direct to `LEGOAssemblyGuideDocs/documentation/legoassemblyguide` and open `index.html` in a web browser