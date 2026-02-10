---
name: flutter-page-design
description: Converts HTML designs to Flutter pages. Use when given an HTML template to create a Flutter page. Creates clean, simple widget classes with proper state management.
---

# Flutter Page Design Skill

When converting HTML to Flutter, follow these strict guidelines:

## Core Principles

1. **ALWAYS use Widget Classes, NEVER Widget Functions**
   - ❌ `Widget buildMyWidget() { return Container(); }`
   - ✅ `class MyWidget extends StatelessWidget { @override Widget build(BuildContext context) { return Container(); } }`

2. **Keep it Simple**
   - No over-engineering
   - No unnecessary abstractions
   - Direct, readable code

## Widget Structure Rules

### StatelessWidget vs StatefulWidget
```dart
// Use StatelessWidget when:
// - No user interaction that changes UI
// - Display-only components

class MyCard extends StatelessWidget {
  const MyCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(...);
  }
}

// Use StatefulWidget when:
// - Form inputs exist
// - Any interactive elements
// - Animations needed

class MyForm extends StatefulWidget {
  const MyForm({super.key});
  
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  // Controllers here
  
  @override
  Widget build(BuildContext context) {
    return Form(...);
  }
}
```

## TextField Requirements - MANDATORY

**EVERY TextField MUST have a TextEditingController**
```dart
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ALWAYS declare controllers as late final or initialize in initState
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  void dispose() {
    // ALWAYS dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _emailController, // NEVER omit this
      decoration: const InputDecoration(
        labelText: 'Email',
      ),
    );
  }
}
```

## HTML to Flutter Mapping

| HTML Element | Flutter Widget |
|-------------|----------------|
| `<div>` | `Container`, `Column`, `Row`, `SizedBox` |
| `<span>`, `<p>`, `<h1-h6>` | `Text` |
| `<img>` | `Image.network`, `Image.asset` |
| `<button>` | `ElevatedButton`, `TextButton`, `OutlinedButton` |
| `<input type="text">` | `TextField` with controller |
| `<input type="password">` | `TextField` with obscureText: true |
| `<input type="checkbox">` | `Checkbox` |
| `<input type="radio">` | `Radio` |
| `<select>` | `DropdownButton`, `DropdownButtonFormField` |
| `<textarea>` | `TextField` with maxLines |
| `<a>` | `GestureDetector`, `InkWell`, `TextButton` |
| `<ul>`, `<ol>` | `ListView`, `Column` with children |
| `<table>` | `Table`, `DataTable` |
| `<form>` | `Form` with GlobalKey<FormState> |

## Layout Mapping

| CSS/HTML Layout | Flutter Equivalent |
|----------------|-------------------|
| `display: flex; flex-direction: row` | `Row` |
| `display: flex; flex-direction: column` | `Column` |
| `display: grid` | `GridView`, `Wrap` |
| `position: absolute` | `Stack` with `Positioned` |
| `margin` | `Container` with margin or `Padding` |
| `padding` | `Padding` widget or Container padding |
| `overflow: scroll` | `SingleChildScrollView`, `ListView` |

## Styling Conversion
```dart
// HTML: style="background-color: #FF5733; border-radius: 8px; padding: 16px;"
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFFFF5733),
    borderRadius: BorderRadius.circular(8),
  ),
  child: ...
)

// HTML: style="font-size: 18px; font-weight: bold; color: #333;"
Text(
  'Hello',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  ),
)
```

## Form Handling - REQUIRED PATTERN
```dart
class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key});
  
  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  // ALWAYS use GlobalKey for Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // ALWAYS declare all controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // For dropdowns, radio buttons, checkboxes - use state variables
  String? _selectedValue;
  bool _isChecked = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Process form
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan zorunludur'; // Turkish: This field is required
              }
              return null;
            },
          ),
          // ... other fields
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Gönder'), // Turkish: Submit
          ),
        ],
      ),
    );
  }
}
```

## Checklist Before Completing

- [ ] All widgets are classes (StatelessWidget or StatefulWidget)
- [ ] NO widget functions anywhere
- [ ] Every TextField has a TextEditingController
- [ ] All controllers are disposed in dispose()
- [ ] Form has GlobalKey<FormState>
- [ ] Const constructors used where possible
- [ ] Proper null safety
- [ ] No hardcoded strings for user-facing text (prepare for localization)

## File Structure
```
lib/
├── pages/
│   └── my_page.dart          # Main page widget
├── widgets/
│   └── my_custom_widget.dart # Reusable components
└── main.dart
```

## Common Mistakes to AVOID

1. ❌ Creating widget functions instead of classes
2. ❌ TextField without controller
3. ❌ Forgetting to dispose controllers
4. ❌ Not using const for immutable widgets
5. ❌ Inline complex widgets instead of extracting to classes
6. ❌ Missing Form key for form validation
7. ❌ Using setState without StatefulWidget

## Example: Complete HTML to Flutter Conversion

### Input HTML:
```html
<div class="login-container">
  <h1>Giriş Yap</h1>
  <form>
    <input type="email" placeholder="E-posta">
    <input type="password" placeholder="Şifre">
    <button type="submit">Giriş</button>
  </form>
</div>
```

### Output Flutter:
```dart
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Login logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'E-posta',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Şifre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Giriş'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```