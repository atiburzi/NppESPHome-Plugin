# NppESPHome-Plugin

A **Notepad++** plugin written in **Delphi** to directly interact with **ESPHome** and easily manage related projects in Windows environment.

![NppESPHome in action](Art/NppESPHome.png)

## Why?

After discovering the potential of ESPHome, I started working on several projects and immediately ran into the lack of a tool that would help me speed up the development workflow, including writing YAML code and performing related testing.
Despite the power of the command line provided by both Python and ESPHome itself, I needed something that would save me from repeatedly rewriting the same commands, even if they were very simple.
At first, I developed a Windows application that acted as a wrapper, but I soon realized that by relying exclusively on Notepad++ for code editing, I could create a plugin that would make interaction with ESPHome commands immediate and straightforward.

That’s how the idea for this plugin was born.

## Features

* Streamlined workflow – Designed around the ESPHome project concept, the plugin ensures a smooth, intuitive, and productive development experience.

* Project configuration dialogs – Quickly select and configure your current project with dedicated setup windows directly inside Notepad++, fully supporting Light or Dark modes.

* One-click ESPHome commands – Automatically generates command lines for Run, Compile, Upload, Clean, and Logs. All commands are accessible from the plugin menu or can be assigned to custom keyboard shortcuts in Notepad++.

* Smart YAML validation – Parses your project’s YAML file to check validity and detect whether it includes Online or WebServer features.

* Flexible device communication – Configure ESP device communication ports with automatic detection of active serial and network connections, making uploads and interaction effortless.

* Command customization – Personalize options for each ESPHome command and save them with your project settings.

* Advanced configuration – Control logging behavior, automatic console closing, and define custom command-line arguments for advanced workflows.

* Auto-save integration – Automatically saves your project files before executing ESPHome commands, helping you keep focus on development.

* Multi-source management – Supports a project dependency file, enabling simultaneous editing of multiple sources within the same project, with multi-file open and save to boost productivity.

* Custom Notepad++ toolbar – An integrated, customizable toolbar provides direct access to the plugin’s main commands and functions.

* Extra utilities – Includes handy non-ESPHome features such as:
    - Opening the official ESPHome web documentation
    - Updating ESPHome to the latest version
    - Launching a command prompt or file explorer directly from the project folder

## What it does and doesn't do

The plugin does not replace ESPHome; instead, it simplifies interaction with it directly from Notepad++.  
For the plugin to work, **ESPHome must already be installed on your system**, and its executable must be available in the user or system PATH.  
As it is built for Notepad++, the editor must also be installed—version 8.0 or higher is required to enable toolbar functionality.

## Typical workflow

1.   Select one or more existing ESPHome projects by adding the corresponding YAML file through the **"Select Project"** plugin command.
    
2.   Choose the active project using the **"Select Project"** plugin command.
    
3.   Configure the current project by setting the relevant options for ESPHome and Notepad++ using the **"Configure Project"** command.
    
4.   Open the project file(s) in Notepad++ for development with the **"Open Project File & Dependencies"** function.
    
5.   Apply your changes.
    
6.   Execute "**Run**", "**Compile**", or "**Upload**" ESPHome commands as needed—either from the menu or through custom keyboard shortcuts.
    
7.   Explore the additional plugin commands and features to further support your development.

## The Application

### "Select Project" functionality

When loaded, the plugin retrieve from the configuration file the current ESPHome project previusly selected.<br/>
The selection and addition of a new project among the known projects can be done through the "Select Project..." function, which will open the following dialog:

![Select Project](Art/select.png)

The combo box list contains all the known ESPHome projects, and the selected one represent the current project for all the other plugin functionalities. To be selected, a project must be part of the project known list.<br/>
To add an ESPHome project to the known list, press the button "Add project" and select the YAML file of your project; it requires a valid YAML project file content and it is analized to retrieve required information.<br/>
In case of an invalid content, an error will be shown and it will not added to the known list.<br/>
To remove an ESPHome project from the known list, select it and press the button "Remove Project".


...to be completed...


## Installation

In case you just want to use the plugin as-is, and don't care to compile it yourself, you can download the [DLL](https://github.com/atiburzi/NppESPHome-Plugin/tree/main/Bin).<br/>
The plugin DLL file should be placed in the plugins subfolder of the Notepad++ Install Folder, under the subfolder with the same name of plugin binary name without file extension, as per this [guide](https://npp-user-manual.org/docs/plugins/#install-plugin-manually).<br/>

Pay attention to use the DLL plugin architecture corresponding to the Notepad++ architecture in use. (x32/x64)<br/>
Moreover, remember that for the plugin to work, ESPHome must already be installed on the system. 
Here you can find the [ESPHome Installation Guide](https://www.esphome.io/guides/installing_esphome/).
If ESPHome is not found during Notepad++ startup, <ins>the plugin will display an error message and it automatically uninstall itself.</ins><br/>

## Plugin settings
Settings are stored in the Notepad++ plugin settings default folder in **NppESPHome.ini** file.

## The Source
[The source](https://github.com/atiburzi/NppESPHome-Plugin/tree/main/Source) (written in Delphi) is available primarily so you can build your own custom versions.
I will accept [pull requests](https://github.com/atiburzi/NppESPHome-Plugin/pulls) for bug fixes that I can reproduce or are obvious.  
Pull requests for new features or other changes should be backed by well argued use cases. 
Start by [creating an issue](https://github.com/atiburzi/NppESPHome-Plugin/issues).

### License
The source code is released under the MPL 2.0 license:
> Copyright © 2025 Andrea Tiburzi  
> This Source Code Form is subject to the terms of the Mozilla Public  
> License, v. 2.0. If a copy of the MPL was not distributed with this  
> file, You can obtain one at http://mozilla.org/MPL/2.0/.

### Environment
NppESPHome plugin has been compiled with Delphi 12 and tested with the following versions but probably works with older (and newer) versions too:
  * Notepad++ 8.8.3
  * ESPHome 2025.3.0

### Dependencies to compile the source
Libraries to interact to Notepad++ have been partially taken from [NppUISpy plugin for Notepad++ ver. 1.2](https://github.com/dinkumoil/NppUISpy/tree/master/src/Lib) and modified to make them working for the plugin.

The following additional 3rd party libraries are required in order to compile the source:
  * [ComPort Library ver. 4.11](http://comport.sf.net/)
  * [LibYAML ver. 0.2.5](https://github.com/yaml/libyaml)
  * [JEDI Visual Component Library ver 3.50](https://github.com/project-jedi/jvcl)

Those libraries must be placed in the Delphi default library search path.