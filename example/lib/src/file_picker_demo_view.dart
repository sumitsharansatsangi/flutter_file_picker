import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerDemoView extends StatelessWidget {
  const FilePickerDemoView({
    super.key,
    required this.scaffoldMessengerKey,
    required this.scaffoldKey,
    required this.defaultFileNameController,
    required this.dialogTitleController,
    required this.initialDirectoryController,
    required this.fileExtensionController,
    required this.isLoading,
    required this.lockParentWindow,
    required this.userAborted,
    required this.multiPick,
    required this.safPersist,
    required this.safReadWrite,
    required this.supportsSafOptions,
    required this.pickingType,
    required this.resultsWidget,
    required this.onPickFiles,
    required this.onPickFileAndDirectoryPaths,
    required this.onSelectFolder,
    required this.onSaveFile,
    required this.onClearCachedFiles,
    required this.onLockParentWindowChanged,
    required this.onMultiPickChanged,
    required this.onSafPersistChanged,
    required this.onSafReadWriteChanged,
    required this.onPickingTypeChanged,
  });

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController defaultFileNameController;
  final TextEditingController dialogTitleController;
  final TextEditingController initialDirectoryController;
  final TextEditingController fileExtensionController;
  final bool isLoading;
  final bool lockParentWindow;
  final bool userAborted;
  final bool multiPick;
  final bool safPersist;
  final bool safReadWrite;
  final bool supportsSafOptions;
  final FileType pickingType;
  final Widget resultsWidget;
  final VoidCallback onPickFiles;
  final VoidCallback onPickFileAndDirectoryPaths;
  final VoidCallback onSelectFolder;
  final VoidCallback onSaveFile;
  final VoidCallback onClearCachedFiles;
  final ValueChanged<bool> onLockParentWindowChanged;
  final ValueChanged<bool> onMultiPickChanged;
  final ValueChanged<bool> onSafPersistChanged;
  final ValueChanged<bool> onSafReadWriteChanged;
  final ValueChanged<FileType> onPickingTypeChanged;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        snackBarTheme:
            const SnackBarThemeData(backgroundColor: Colors.deepPurple),
      ),
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(title: const Text('File Picker example app')),
        body: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Configuration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    SizedBox(
                      width: 400,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Dialog Title',
                        ),
                        controller: dialogTitleController,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Initial Directory',
                        ),
                        controller: initialDirectoryController,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Default File Name',
                        ),
                        controller: defaultFileNameController,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: DropdownButtonFormField<FileType>(
                        // ignore: deprecated_member_use
                        value: pickingType,
                        icon: const Icon(Icons.expand_more),
                        alignment: Alignment.centerLeft,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: FileType.values
                            .map(
                              (fileType) => DropdownMenuItem<FileType>(
                                value: fileType,
                                child: Text(fileType.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onPickingTypeChanged(value);
                          }
                        },
                      ),
                    ),
                    pickingType == FileType.custom
                        ? SizedBox(
                            width: 400,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'File Extension',
                                hintText: 'jpg, png, gif',
                              ),
                              autovalidateMode: AutovalidateMode.always,
                              controller: fileExtensionController,
                              keyboardType: TextInputType.text,
                              maxLength: 15,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 20.0),
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  direction: Axis.horizontal,
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    SizedBox(
                      width: 400.0,
                      child: SwitchListTile.adaptive(
                        title: const Text(
                          'Lock parent window',
                          textAlign: TextAlign.left,
                        ),
                        onChanged: onLockParentWindowChanged,
                        value: lockParentWindow,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 400.0),
                      child: SwitchListTile.adaptive(
                        title: const Text(
                          'Pick multiple files',
                          textAlign: TextAlign.left,
                        ),
                        onChanged: onMultiPickChanged,
                        value: multiPick,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 400.0),
                      child: SwitchListTile.adaptive(
                        title: const Text(
                          'SAF Persist (Android 10+)',
                          textAlign: TextAlign.left,
                        ),
                        onChanged:
                            supportsSafOptions ? onSafPersistChanged : null,
                        value: safPersist,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 400.0),
                      child: SwitchListTile.adaptive(
                        title: const Text(
                          'SAF ReadWrite (Android 10+)',
                          textAlign: TextAlign.left,
                        ),
                        onChanged:
                            supportsSafOptions ? onSafReadWriteChanged : null,
                        value: safReadWrite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Divider(),
                const SizedBox(height: 20.0),
                const Text(
                  'Actions',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: <Widget>[
                      SizedBox(
                        width: 120,
                        child: FloatingActionButton.extended(
                          onPressed: onPickFiles,
                          label: Text(multiPick ? 'Pick files' : 'Pick file'),
                          icon: const Icon(Icons.description),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: FloatingActionButton.extended(
                          onPressed: onSelectFolder,
                          label: const Text('Pick folder'),
                          icon: const Icon(Icons.folder),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: FloatingActionButton.extended(
                          onPressed: onPickFileAndDirectoryPaths,
                          label: const Text('Pick files and directories'),
                          icon: const Icon(Icons.folder_open),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: FloatingActionButton.extended(
                          onPressed: onSaveFile,
                          label: const Text('Save file'),
                          icon: const Icon(Icons.save_as),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: FloatingActionButton.extended(
                          onPressed: onClearCachedFiles,
                          label: const Text('Clear temporary files'),
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 20.0),
                const Text(
                  'File Picker Result',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Builder(
                  builder: (BuildContext context) => isLoading
                      ? Row(
                          children: const [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 40.0,
                                  ),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : userAborted
                          ? Row(
                              children: const [
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 300,
                                      child: ListTile(
                                        leading: Icon(Icons.error_outline),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 40.0,
                                        ),
                                        title: Text(
                                          'User has aborted the dialog',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : resultsWidget,
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
