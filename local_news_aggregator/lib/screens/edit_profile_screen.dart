import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;
  late TextEditingController _defaultCityController;
  late TextEditingController _defaultStateController;
  late TextEditingController _defaultCountryController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _imageUrlController = TextEditingController(
      text: user?.profileImageUrl ?? '',
    );
    _defaultCityController = TextEditingController(
      text: user?.defaultCity ?? '',
    );
    _defaultStateController = TextEditingController(
      text: user?.defaultState ?? '',
    );
    _defaultCountryController = TextEditingController(
      text: user?.defaultCountry ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _defaultCityController.dispose();
    _defaultStateController.dispose();
    _defaultCountryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final success = await authService.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      location: _locationController.text.trim(),
      profileImageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      defaultCity: _defaultCityController.text.trim().isEmpty
          ? null
          : _defaultCityController.text.trim(),
      defaultState: _defaultStateController.text.trim().isEmpty
          ? null
          : _defaultStateController.text.trim(),
      defaultCountry: _defaultCountryController.text.trim().isEmpty
          ? null
          : _defaultCountryController.text.trim(),
    );

    if (!mounted) return;
    showMessage(
      context,
      success ? 'Profile updated successfully!' : 'Failed to update profile',
      isError: !success,
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: authService.isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: authService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _imageUrlController.text.isNotEmpty
                                ? NetworkImage(_imageUrlController.text)
                                : null,
                            child: _imageUrlController.text.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _showImageUrlDialog();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: validateName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., New York, USA',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about yourself',
                        prefixIcon: Icon(Icons.info),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      thickness: 1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Default News Filters',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set your preferred location for local news',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _defaultCityController,
                      decoration: const InputDecoration(
                        labelText: 'Default City',
                        hintText: 'e.g., New York',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _defaultStateController,
                      decoration: const InputDecoration(
                        labelText: 'Default State/Province',
                        hintText: 'e.g., California',
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _defaultCountryController,
                      decoration: const InputDecoration(
                        labelText: 'Default Country',
                        hintText: 'e.g., United States',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
          text: _imageUrlController.text,
        );
        return AlertDialog(
          title: const Text('Profile Image URL'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter image URL',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _imageUrlController.text = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
