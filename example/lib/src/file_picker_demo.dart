// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'file_picker_results.dart';
import 'file_picker_demo_view.dart';
import 'picked_directory_result.dart';
import 'picked_files_results.dart';

class FilePickerDemo extends StatefulWidget {
  const FilePickerDemo({super.key});

  @override
  State<FilePickerDemo> createState() => _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  static const MethodChannel _androidSafSupportChannel = MethodChannel(
    'com.mr.flutter.plugins.filepicker/android_saf_support',
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _defaultFileNameController = TextEditingController();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  final _fileExtensionController = TextEditingController();
  String? _extension;
  bool _isLoading = false;
  bool _lockParentWindow = false;
  bool _userAborted = false;
  bool _multiPick = false;
  bool _safPersist = false;
  bool _safReadWrite = false;
  bool _supportsSafOptions = false;
  FileType _pickingType = FileType.any;
  List<PlatformFile>? pickedFiles;
  Widget _resultsWidget = const Row(
    children: [
      Expanded(
        child: Center(
          child: SizedBox(
            width: 300,
            child: ListTile(
              leading: Icon(Icons.error_outline),
              contentPadding: EdgeInsets.symmetric(vertical: 40.0),
              title: Text('No action taken yet'),
              subtitle: Text(
                'Please use on one of the buttons above to get started',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _fileExtensionController.addListener(
      () => _extension = _fileExtensionController.text,
    );
    _loadSafSupport();
  }

  Future<void> _loadSafSupport() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final sdkInt =
          await _androidSafSupportChannel.invokeMethod<int>('getSdkInt');
      if (!mounted) return;
      setState(() {
        _supportsSafOptions = (sdkInt ?? 0) >= 29;
        if (!_supportsSafOptions) {
          _safPersist = false;
          _safReadWrite = false;
        }
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    }
  }

  void _pickFiles() async {
    bool hasUserAborted = true;
    _resetState();

    try {
      final result = await FilePicker.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        onFileLoading: (FilePickerStatus status) => setState(() {
          _isLoading = status == FilePickerStatus.picking;
        }),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
        withData: true,
        androidSafOptions: AndroidSAFOptions(
          grant: _safPersist
              ? AndroidSAFGrant.lifetime
              : AndroidSAFGrant.transient,
          accessMode: _safReadWrite
              ? AndroidSAFAccessMode.readWrite
              : AndroidSAFAccessMode.readOnly,
        ),
      );
      printInDebug("pickedFiles: $result");
      pickedFiles = result?.files;
      hasUserAborted = pickedFiles == null;
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _userAborted = hasUserAborted;

      void updateResults() {
        _resultsWidget = PickedFilesResults(
          pickedFiles: pickedFiles,
          onRemoveAndroidFile:
              (int index, AndroidPlatformFile androidPlatformFile) {
            androidPlatformFile.safHandle.releaseGrant();
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text("SAF Permission Released!"),
              ),
            );
            setState(() {
              pickedFiles!.removeAt(index);
              updateResults();
            });
          },
        );
      }

      updateResults();
    });
  }

  void _pickFileAndDirectoryPaths() async {
    List<String>? pickedFilesAndDirectories;
    bool hasUserAborted = true;
    _resetState();

    try {
      pickedFilesAndDirectories = await FilePicker.pickFileAndDirectoryPaths(
        type: _pickingType,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        initialDirectory: _initialDirectoryController.text,
      );
      hasUserAborted = pickedFilesAndDirectories == null;
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _userAborted = hasUserAborted;
      _resultsWidget = FilePickerResultsList(
        itemCount: pickedFilesAndDirectories?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          String name = 'File path:';
          if (!kIsWeb) {
            final fs = LocalFileSystem();
            name = fs.isFileSync(pickedFilesAndDirectories![index])
                ? 'File path:'
                : 'Directory path:';
          }
          return ListTile(
            leading: Text(
              index.toString(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            title: Text(name),
            subtitle: Text(pickedFilesAndDirectories![index]),
          );
        },
      );
    });
  }

  void _clearCachedFiles() async {
    pickedFiles = [];
    _resetState();
    try {
      bool? result = await FilePicker.clearTemporaryFiles();
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            (result!
                ? 'Temporary files removed with success.'
                : 'Failed to clean temporary files'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    } catch (e) {
      _logException(e.toString());
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _selectFolder() async {
    String? pickedDirectoryPath;
    bool hasUserAborted = true;
    _resetState();

    try {
      pickedDirectoryPath = await FilePicker.getDirectoryPath(
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
        androidSafOptions: AndroidSAFOptions(
          grant: _safPersist
              ? AndroidSAFGrant.lifetime
              : AndroidSAFGrant.transient,
          accessMode: _safReadWrite
              ? AndroidSAFAccessMode.readWrite
              : AndroidSAFAccessMode.readOnly,
        ),
      );
      hasUserAborted = pickedDirectoryPath == null;
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    } catch (e) {
      _logException(e.toString());
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _userAborted = hasUserAborted;
      void updateResults() {
        _resultsWidget = PickedDirectoryResult(
          pickedDirectoryPath: pickedDirectoryPath,
          readWriteAccess: _safReadWrite,
          onDirectoryRemoved: () {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text("SAF Permission Released!"),
              ),
            );
            setState(() {
              pickedDirectoryPath = null;
              updateResults();
            });
          },
        );
      }

      updateResults();
    });
  }

  Future<void> _saveFile() async {
    String? pickedSaveFilePath;
    bool hasUserAborted = true;
    _resetState();

    try {
      pickedSaveFilePath = await FilePicker.saveFile(
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        type: FileType.custom,
        dialogTitle: _dialogTitleController.text,
        fileName: _defaultFileNameController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
        bytes: pickedFiles?.first.bytes,
      );
      hasUserAborted = pickedSaveFilePath == null;
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _userAborted = hasUserAborted;
      _resultsWidget = FilePickerResultsList(
        itemCount: pickedSaveFilePath != null ? 1 : 0,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: const Text('Save file path:'),
            subtitle: Text(pickedSaveFilePath ?? ''),
          );
        },
      );
    });
  }

  void _logException(String message) {
    printInDebug(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _resetState() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _userAborted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilePickerDemoView(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      scaffoldKey: _scaffoldKey,
      defaultFileNameController: _defaultFileNameController,
      dialogTitleController: _dialogTitleController,
      initialDirectoryController: _initialDirectoryController,
      fileExtensionController: _fileExtensionController,
      isLoading: _isLoading,
      lockParentWindow: _lockParentWindow,
      userAborted: _userAborted,
      multiPick: _multiPick,
      safPersist: _safPersist,
      safReadWrite: _safReadWrite,
      supportsSafOptions: _supportsSafOptions,
      pickingType: _pickingType,
      resultsWidget: _resultsWidget,
      onPickFiles: _pickFiles,
      onPickFileAndDirectoryPaths: _pickFileAndDirectoryPaths,
      onSelectFolder: _selectFolder,
      onSaveFile: _saveFile,
      onClearCachedFiles: _clearCachedFiles,
      onLockParentWindowChanged: (value) =>
          setState(() => _lockParentWindow = value),
      onMultiPickChanged: (value) => setState(() => _multiPick = value),
      onSafPersistChanged: (value) => setState(() => _safPersist = value),
      onSafReadWriteChanged: (value) => setState(() => _safReadWrite = value),
      onPickingTypeChanged: (value) => setState(() {
        _pickingType = value;
        if (_pickingType != FileType.custom) {
          _fileExtensionController.text = _extension = '';
        }
      }),
    );
  }

  void printInDebug(Object object) => debugPrint(object.toString());
}
