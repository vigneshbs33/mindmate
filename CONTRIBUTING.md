# Contributing to MindMate

Thank you for your interest in contributing to MindMate! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
- Use the GitHub issue tracker
- Search existing issues before creating new ones
- Use clear, descriptive titles
- Include steps to reproduce bugs
- Specify your environment (OS, Flutter version, etc.)

### Suggesting Features
- Check existing feature requests first
- Provide clear use cases and benefits
- Consider the app's focus on mental health and privacy

### Code Contributions
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Add tests if applicable
5. Run the linter: `flutter analyze`
6. Run tests: `flutter test`
7. Commit with clear messages
8. Push to your fork
9. Create a Pull Request

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.4.0 or higher
- Dart SDK 3.0.0 or higher
- Git
- IDE (VS Code, Android Studio, or IntelliJ)

### Setup Steps
1. Clone your fork: `git clone https://github.com/yourusername/mindmate.git`
2. Navigate to project: `cd mindmate`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible

### Testing
- Write unit tests for business logic
- Test UI components with widget tests
- Ensure all tests pass before submitting PR

## 📋 Pull Request Guidelines

### Before Submitting
- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] No linter warnings
- [ ] Documentation updated if needed
- [ ] Commit messages are clear

### PR Description
- Describe what the PR does
- Reference related issues
- Include screenshots for UI changes
- List any breaking changes

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── app.dart             # Main app widget
│   ├── models/              # Data models
│   ├── providers/           # State management (Riverpod)
│   ├── screens/             # UI screens
│   ├── services/            # Business logic
│   └── theme/               # App theming
```

### Key Principles
- **Offline-First**: App should work without internet
- **Privacy**: No user data collection
- **Accessibility**: Support all users
- **Performance**: Smooth, responsive UI

## 🎯 Areas for Contribution

### High Priority
- Bug fixes
- Performance improvements
- Accessibility enhancements
- Documentation improvements

### Medium Priority
- New features aligned with mental health focus
- UI/UX improvements
- Test coverage
- Code refactoring

### Low Priority
- Nice-to-have features
- Experimental features
- Third-party integrations

## 🐛 Bug Reports

When reporting bugs, please include:
- Flutter version: `flutter --version`
- Device/OS information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Logs if available

## 💡 Feature Requests

For feature requests, please:
- Check existing issues first
- Explain the use case
- Consider privacy implications
- Think about offline functionality
- Consider accessibility

## 📝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Respect different perspectives
- Follow the golden rule

## 🏷️ Labels

We use labels to categorize issues and PRs:
- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `question`: Further information is requested

## 📞 Getting Help

- Check existing issues and discussions
- Join our community discussions
- Ask questions in GitHub Discussions
- Be patient - we're all volunteers

## 🎉 Recognition

Contributors will be:
- Listed in the README
- Mentioned in release notes
- Given credit in the app (if desired)

Thank you for contributing to MindMate! Together, we can make mental health support more accessible and effective.
