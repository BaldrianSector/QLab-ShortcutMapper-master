Tidy Workspace Shortcut Mapper
==================

This is a keyboard shortcut visualiser for [QLab](https://qlab.app/) hosted here on Github:

https://baldriansector.github.io/QLab-ShortcutMapper-master/

The project is built by [@BaldrianSector](https://www.facebook.com/baldriansector) for [Tidywork.space](https://tidywork.space) on [code by Waldo Bronchart](https://github.com/waldobronchart/ShortcutMapper) and [stylesheet inspired by FastPrint.co.uk](http://www.fastprint.co.uk/adobe-shortcut-mapper/)

Tidy Workspace Shortcut Mapper is made to help get an overview of your QLab Tidy Workspace Template, explore new shortcuts and to help you get them into your workflow. There is also an integrated version of the Default Shortcuts.

## Updating Shortcuts

I regularly update the shortcuts every time a new version of the Tidywork.space template is updated, but also to keep them up to date with the most recent QLab changes made by Figure53. However, be aware that I am not affiliated with Figure53 and I don’t have any direct influence on changes, so updating might take time, depending on the situation.

I do have a script to extract shortcuts from QLab, but there are a lot of things to be aware of. Optimally every shortcut is checked manually, so it takes some time. I'm not ready to share the export script yet, so there is not currently a way to quickly set it up with a custom template. That being said, I hope to eventually upload a script here, so you can quickly generate your own set of shortcuts.

# Overview

This project is directly hosted on github from the **master** branch. All changes to this branch are live.

```
/content         The website content
    /generated   Contains generated json/js files containing application
                  shortcut data in the site format
    /keyboards   Contains html keyboard layouts
    ...
/sources         Source data for shortcuts per application.
/shmaplib        Python utility library (Shortcut Mapper Lib) to help 
                  exporting shortcuts to the webapp.
/tests           Python tests to ensure nothing is broken
/utils           Utilities for exporting and testing
index.html       Main site page
```

# Contributing

If you are looking to help out with the development of this project, please feel free to reach out. 

## Running locally

Before opening pull requests to contribute, you should test your changes locally.

The easiest way to run locally is to run a simple http server:
1. Install http-server via npm: `npm install -g http-server`
2. Run `http-server` in your terminal with the directory of your local files
  > Starting up http-server, serving ./
  > Available on:
  >   http://127.0.0.1:8080
  >   http://192.168.86.95:8080
  > Hit CTRL-C to stop the server
3. Go to http://127.0.0.1:8080 in your browser

If you need more information, please check the [code by Waldo Bronchart](https://github.com/waldobronchart/ShortcutMapper)

Regarding pull requests, you'll create a branch like `feature/descriptive-feature-name` from the `master` branch and start working in that. Once you're done, you'll create a pull request that merges into the `dev` branch.
This allows me to test your changes before it is published to the `master` branch.

For bug fixes, you'll name your branch `fix/descriptive-bug-name`.

### Disclaimer

Figure 53® and QLab® are registered trademarks of Figure 53, LLC.
Tidy Workspace Shortcut Mapper is not affiliated with Figure 53, LLC and this code has not been reviewed nor is it approved by Figure 53, LLC
