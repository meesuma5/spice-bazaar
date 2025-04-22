import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:uicons/uicons.dart';
import 'package:uicons_updated/icons/uicons_regular.dart';

// Create a new file for your profile drawer
class ProfileDrawer extends StatelessWidget {
  final User user;
  const ProfileDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(UiconsRegular.cross),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  user.profileImageUrl == ''
                      ? baseProfileImageLink
                      : user.profileImageUrl ??
                          baseProfileImageLink, // Sample avatar image
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user.username,
                style: poppins(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Edit Profile',
                  onPressed: () {},
                  isOutlined: true,
                  icon: Icon(UIcons.regularStraight.pencil,
                      color: Colors.black87, size: 14),
                  vPad: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCountInfo(user.createdRecipes.toString(), 'Recipes'),
                  const SizedBox(
                    width: 16,
                  ),
                  _buildCountInfo(
                      user.bookmarkedRecipes.toString(), 'Bookmarks'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoSection('Email', user.email),
            const SizedBox(height: 12),
            _buildInfoSection('Joined', user.regDate),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {},
                  text: 'Log Out',
                  color: Colors.red,
                  isOutlined: true,
                  icon: Icon(UIcons.regularRounded.sign_out_alt,
                      color: Colors.red, size: 16),
                  vPad: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountInfo(String count, String label) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: halfOpacityGray,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              count,
              style: poppins(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              label,
              style: poppins(
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: poppins(
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )),
          const SizedBox(height: 4),
          Text(
            content,
            style: poppins(
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
