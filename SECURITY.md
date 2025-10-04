# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow these steps:

### 1. **DO NOT** create a public GitHub issue

Security vulnerabilities should be reported privately to protect our users.

### 2. Email us directly

Send an email to: **security@mindmate.app**

Include the following information:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
- Your contact information

### 3. Response timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 7 days
- **Resolution**: As quickly as possible

### 4. What to expect

- We will acknowledge receipt of your report
- We will investigate and validate the issue
- We will work on a fix
- We will coordinate disclosure with you
- We will credit you (if desired) in our security advisories

## Security Features

### Data Protection
- **Local Storage**: All data is stored locally on your device
- **Encryption**: Sensitive data is encrypted using Flutter Secure Storage
- **No Cloud Sync**: Your data never leaves your device unless you explicitly export it
- **No Tracking**: We don't collect any analytics or user data

### Authentication
- **Biometric Support**: Optional fingerprint/face recognition
- **No Passwords**: No password-based authentication to avoid security risks
- **Device-Only**: Authentication is tied to your device

### Privacy
- **Offline-First**: App works without internet connection
- **No Data Collection**: We don't collect any personal information
- **Open Source**: All code is publicly available for review
- **No Third-Party Analytics**: No tracking or analytics services

### API Security
- **API Keys**: Stored securely using Flutter Secure Storage
- **No Data Transmission**: Journal entries are not sent to external services
- **Optional AI**: AI features are completely optional and can be disabled
- **Free APIs Only**: Only uses free tiers of AI services

## Security Best Practices

### For Users
1. **Keep your device updated**: Regular OS updates include security patches
2. **Use biometric authentication**: Enable device-level security
3. **Regular backups**: Export your data regularly
4. **Secure device**: Use device lock screen and encryption
5. **Review permissions**: Only grant necessary permissions

### For Developers
1. **Code review**: All code changes are reviewed
2. **Dependency updates**: Regular updates of dependencies
3. **Security scanning**: Automated security checks in CI/CD
4. **Minimal permissions**: Request only necessary permissions
5. **Secure storage**: Use Flutter Secure Storage for sensitive data

## Security Audit

We regularly audit our code for security issues:

- **Static Analysis**: Automated code analysis
- **Dependency Scanning**: Regular dependency vulnerability checks
- **Code Review**: Manual code review process
- **Penetration Testing**: Regular security testing
- **Third-Party Audits**: External security reviews

## Vulnerability Disclosure

When we discover or are notified of a security vulnerability:

1. **Assessment**: We assess the severity and impact
2. **Fix Development**: We develop a fix as quickly as possible
3. **Testing**: We thoroughly test the fix
4. **Release**: We release the fix in a new version
5. **Disclosure**: We publish a security advisory
6. **Communication**: We notify users through appropriate channels

## Security Advisories

Security advisories are published in:
- [GitHub Security Advisories](https://github.com/yourusername/mindmate/security/advisories)
- [Releases page](https://github.com/yourusername/mindmate/releases)
- [CHANGELOG.md](CHANGELOG.md)

## Contact

For security-related questions or concerns:
- **Email**: security@mindmate.app
- **GitHub**: [Security Advisories](https://github.com/yourusername/mindmate/security/advisories)
- **Issues**: [GitHub Issues](https://github.com/yourusername/mindmate/issues) (for non-security issues)

## Acknowledgments

We thank all security researchers who responsibly disclose vulnerabilities to us.

## Legal

This security policy is subject to our [Terms of Service](TERMS.md) and [Privacy Policy](PRIVACY.md).

---

**Last updated**: December 19, 2024
