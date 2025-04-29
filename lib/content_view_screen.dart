import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
class ContentViewScreen extends StatefulWidget {
  final String folderPath;
  final String title;

  ContentViewScreen({required this.folderPath, required this.title});

  @override
  _ContentViewScreenState createState() => _ContentViewScreenState();
}

class _ContentViewScreenState extends State<ContentViewScreen> {
  List<Map<String, dynamic>> files = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  /// **🔹 Fetch Files from Firebase Storage**
  Future<void> fetchFiles() async {
    print("🔍 Fetching files from Firebase Storage Path: ${widget.folderPath}");

    try {
      ListResult result = await FirebaseStorage.instance.ref(widget.folderPath)
          .listAll();
      List<Map<String, dynamic>> fileList = [];

      for (var fileRef in result.items) {
        // Skip the .keep file
        if (fileRef.name == '.keep') continue;

        String url = await fileRef.getDownloadURL();
        fileList.add({"name": fileRef.name, "url": url});
      }

      if (fileList.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "No files found in this folder.";
        });
      } else {
        setState(() {
          files = fileList;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to fetch files: $e";
      });
    }
  }


  /// **📂 Open File in Browser**
  Future<void> openFile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open file!")),
      );
    }
  }

  // ContentViewScreen
  void viewFileInApp(String fileName, String fileUrl) {
    String extension = fileName
        .split(".")
        .last
        .toLowerCase();

    if (["pdf"].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFViewerScreen(pdfUrl: fileUrl)),
      );
    } else if (["jpg", "jpeg", "png"].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewerScreen(imageUrl: fileUrl)),
      );
    } else if (["doc", "docx", "ppt", "pptx", "xls", "xlsx", "txt"].contains(
        extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewScreen(fileUrl: fileUrl)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("File format not supported for in-app viewing!")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 2,
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeData.brightness == Brightness.dark
                  ? Icons.wb_sunny // Sun for Light Mode
                  : Icons.nightlight_round, // Moon for Dark Mode
              color: Colors.white,
            ),
            onPressed: () {
              // Toggle the theme using the provider
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          )

        ],

      ),
      body:
      Padding(



        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: isLoading
            ? buildShimmerEffect()
            : errorMessage.isNotEmpty
            ? buildEmptyState(errorMessage)
            : files.isEmpty
            ? buildEmptyState("No files found in this folder.")
            : ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            String fileName = files[index]["name"];
            String fileUrl = files[index]["url"];
            IconData fileIcon = getFileIcon(fileName);

            return GestureDetector(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
              //   color: Colors.white,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800] // Dark grey for dark mode
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Icon(fileIcon, color: Colors.deepPurple),
                  ),
                  title: Text(
                    fileName,
                    style:  Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "view") {
                        viewFileInApp(fileName, fileUrl);
                      } else if (value == "download") {
                        openFile(fileUrl);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "view",
                        child: Row(
                          children: [Icon(Icons.visibility, color: Colors.deepPurple), SizedBox(width: 8), Text("View")],
                        ),
                      ),
                      PopupMenuItem(
                        value: "download",
                        child: Row(
                          children: [Icon(Icons.download, color: Colors.deepPurple), SizedBox(width: 8), Text("Download")],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

    );
  }

  /// **📂 Get File Type Icon**
  IconData getFileIcon(String fileName) {
    String ext = fileName.split(".").last.toLowerCase();
    switch (ext) {
      case "pdf":
        return Icons.picture_as_pdf;
      case "doc":
      case "docx":
        return Icons.description;
      case "ppt":
      case "pptx":
        return Icons.slideshow;
      case "xls":
      case "xlsx":
        return Icons.table_chart;
      case "txt":
        return Icons.text_snippet;
      case "jpg":
      case "jpeg":
      case "png":
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// **📄 PDF Viewer**
class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  PDFViewerScreen({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: PDFView(
        filePath: pdfUrl,
      ),
    );
  }
}

/// **🖼 Image Viewer**
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  ImageViewerScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Viewer")),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}



Widget buildShimmerEffect() {
  return Center(
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        width: double.infinity,
        color: Colors.white,
      ),
    ),
  );
}
Widget buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red, size: 50),
        SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

// WebViewScreen - The code changes in this screen handle file viewing using webview
class WebViewScreen extends StatefulWidget {
  final String fileUrl;

  WebViewScreen({required this.fileUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
              print("WebView loaded successfully: $url");
            }
          },
        ),
      );

    // Load the appropriate URL
    _loadUrl();
  }

  void _loadUrl() {
    final url = widget.fileUrl;
    print("Attempting to load document URL: $url");

    // For Microsoft Office documents, use Office Online Viewer
    if (url.contains('.doc') || url.contains('.xls') || url.contains('.ppt')) {
      final encodedUrl = Uri.encodeComponent(url);
      final officeViewerUrl = 'https://view.officeapps.live.com/op/view.aspx?src=$encodedUrl';
      print("Using Office Online Viewer: $officeViewerUrl");
      controller.loadRequest(Uri.parse(officeViewerUrl));
    }
    // For PDF files, use Google Docs viewer
    else if (url.toLowerCase().endsWith('.pdf')) {
      final encodedUrl = Uri.encodeComponent(url);
      final pdfViewerUrl = 'https://docs.google.com/viewer?url=$encodedUrl&embedded=true';
      print("Using Google Docs viewer: $pdfViewerUrl");
      controller.loadRequest(Uri.parse(pdfViewerUrl));
    }
    // For text files
    else if (url.toLowerCase().endsWith('.txt')) {
      controller.loadRequest(Uri.parse(url));
    }
    // Regular URL handling
    else {
      controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document Viewer"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () async {
              final url = Uri.parse(widget.fileUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Cannot open in browser")),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
