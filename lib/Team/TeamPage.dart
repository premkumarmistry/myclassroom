import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamPage extends StatelessWidget {
  final List<TeamMember> teamMembers = [
    TeamMember(
      name: "Premkumar Mistry",
      email: "premsahebrajmistry@gmail.com",
      description: "A passionate Flutter developer with a knack for UI design.",
      imageUrl: "assets/premone.png", // Example image URL
      linkedinUrl: "https://in.linkedin.com/in/premmistry",
      githubUrl: "https://github.com/premkumarmistry",
    ),
    TeamMember(
      name: "Hirenkumar Vasava",
      email: "hirenvasava@gmail.com",
      description: "Full-stack developer with experience in  Nextjs and cloud computing.",
      imageUrl: "assets/hiren.png", // Example image URL
      linkedinUrl: "https://www.linkedin.com/in/janesmith/",
      githubUrl: "https://github.com/janesmith",
    ),
    TeamMember(
      name: "Yakulkumar Vasava",
      email: "yakulkumarvasava@gmail.com",
      description: "Mobile app developer with a focus on Flutter and Android.",
      imageUrl: "assets/yakul.png", // Example image URL
      linkedinUrl: "https://www.linkedin.com/in/alicejohnson/",
      githubUrl: "https://github.com/alicejohnson",
    ),
    TeamMember(
      name: "Ravishankar Wakode",
      email: "Ravishankarwakode@gmail.com",
      description: "Backend developer specializing in Node.js and databases.",
      imageUrl: "assets/ravi.png", // Example image URL
      linkedinUrl: "https://www.linkedin.com/in/bobbrown/",
      githubUrl: "https://github.com/bobbrown",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Development Team"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Dark mode toggle button
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            return TeamMemberCard(teamMember: teamMembers[index]);
          },
        ),
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String email;
  final String description;
  final String imageUrl;
  final String linkedinUrl;
  final String githubUrl;

  TeamMember({
    required this.name,
    required this.email,
    required this.description,
    required this.imageUrl,
    required this.linkedinUrl,
    required this.githubUrl,
  });
}

class TeamMemberCard extends StatelessWidget {
  final TeamMember teamMember;

  const TeamMemberCard({required this.teamMember});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child:   Image.asset(
                  '${teamMember.imageUrl}',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, color: Colors.red); // fallback if image fails
                  },
                )

            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    teamMember.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  // Email
                  Text(
                    teamMember.email,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Description
                  Text(
                    teamMember.description,
                    style:  Theme.of(context).textTheme.bodySmall,

                  ),
                  //SizedBox(height: 12),
                  // Social Media Links (LinkedIn, GitHub)
                  Row(
                    children: [
                      SocialIconButton(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/LinkedIn_icon_circle.svg/1200px-LinkedIn_icon_circle.svg.png', // LinkedIn logo URL
                        url: teamMember.linkedinUrl,
                      ),
                      SocialIconButton(
                        imageUrl: 'https://i.postimg.cc/fb30YRSN/image-removebg-preview-3.png', // LinkedIn logo URL
                        url: teamMember.githubUrl,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialIconButton extends StatelessWidget {
  final String imageUrl;
  final String url;

  const SocialIconButton({required this.imageUrl, required this.url});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.network(
        imageUrl,
        width: 30,  // Adjust size as necessary
        height: 30,
      ),
      onPressed: () => _launchURL(url),
    );
  }

  // Launch URLs (LinkedIn, GitHub, etc.)
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
