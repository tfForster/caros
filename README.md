# test_app
A template for new flutter applications.

## Getting Started

This project is an empty flutter application with a Serverconnection implementation
and a few custom Widgets.

To get started please:
1. create a new folder with your desired appname (can only contain lowercase letters and '_', must start with lowercase letter) 
2. cd into it
3. use the following:

```git
git clone https://git.eder-gmbh.intern/Eder_GmbH/FlutterTemplate .
```

**Note the . at the end of the expression!**

4. run the included script:

```powershell
powershell ./rename_project.ps1
```

**Voilà, the app template is now ready!**


## Powershell script overview

The above script does the following:
- names the project and all its mentions like the name of the Folder you created.
- asks for your:
    - name 
    - a title 
    - first version
- checks if the parent folder is named according to the flutter app naming conventions
- creates a new git repository
- makes the initial commit for you.
