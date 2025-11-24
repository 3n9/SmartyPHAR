# Smarty PHAR Builder

> **_NOTE:_** This project was primarily generated using AI. It's provided as-is for community use and contributions are welcome.

Build and use the [Smarty template engine](https://github.com/smarty-php/smarty) as a single, portable PHAR file.

## ⚠️ Important Warning

**This is a TEMPORARY solution** for specific legacy scenarios only:
- ✅ Legacy systems with FTP-only access
- ✅ Quick prototyping without full development environment
- ✅ Shared hosting without Composer/SSH access
- ✅ Learning Smarty without command-line tools

**NOT recommended for:**
- ❌ Production web services
- ❌ Modern PHP projects with proper dependency management
- ❌ Long-term solutions
- ❌ Projects that can use Composer

**For proper production applications, always use the official method:**
```bash
composer require smarty/smarty
```

This PHAR approach is a convenience workaround for situations where Composer is not available. Migrate to Composer-based dependency management as soon as possible.

## 🚀 Quick Start

### For Non-Technical Users (No Command Line Required)

1. **Download** a pre-built PHAR from the [Releases](../../releases) page:
   - `Smarty-v5.7.0.phar` - For PHP 8.1+ (recommended for new projects)
   - `Smarty-v4.5.6.phar` - For PHP 7.2 to 8.x
   - `Smarty-v3.1.46.phar` - For legacy PHP 5.6+ systems

2. **Upload via FTP** to your web server (e.g., into your public_html folder)

3. **Create a writable directory** called `templates_c` (set permissions to 755 or 777)

4. **Use in your PHP file:**

```php
<?php
// Include the PHAR file
require 'Smarty-v5.7.0.phar';

// Create Smarty instance
$smarty = new Smarty\Smarty();

// Configure directories
$smarty->setTemplateDir('./templates');      // Where your .tpl files are
$smarty->setCompileDir('./templates_c');     // Must be writable!

// Simple inline template (no files needed)
echo $smarty->fetch('string:Hello {$name}!', ['name' => 'World']);
```

That's it! No Composer, no command line, no complex setup.

**For Smarty usage and template syntax, see the [Official Smarty Documentation](https://www.smarty.net/docs/en/).**

## 🔧 Build Your Own PHAR

**Requirements:**
- PHP with `phar` extension enabled
- Composer installed
- Network access (for downloading dependencies)

**Basic usage:**
```bash
./build-smarty-phar.sh
```

Output: `dist/Smarty-v{resolved_version}.phar`

**Configuration options:**

| Variable | Default | Description |
|----------|---------|-------------|
| `SMARTY_MAJOR` | `5` | Target Smarty major version (3, 4, or 5) |
| `PROJECT_DIR` | `build` | Temporary Composer workspace |
| `OUTPUT_DIR` | `dist` | Where the PHAR is written |
| `OUTPUT_PHAR` | (auto) | Override full output path/name |
| `ALLOW_DIR_REUSE` | `0` | Reuse non-empty PROJECT_DIR |
| `ALLOW_PHAR_OVERWRITE` | `0` | Overwrite existing PHAR |
| `KEEP_PROJECT_DIR` | `0` | Keep temp directory after build |
| `COMPOSER_BIN` | `composer` | Path to Composer binary |

**Examples:**

```bash
# Latest Smarty 5.x (default)
./build-smarty-phar.sh

# Latest Smarty 3.x, overwrite existing
SMARTY_MAJOR=3 ALLOW_PHAR_OVERWRITE=1 ./build-smarty-phar.sh

# Build all major versions
for v in 3 4 5; do 
  SMARTY_MAJOR=$v ALLOW_PHAR_OVERWRITE=1 ./build-smarty-phar.sh
done

# Custom output name
OUTPUT_PHAR=dist/smarty-custom.phar ./build-smarty-phar.sh
```

## 🧪 Testing

Verify a built PHAR works correctly:

```bash
php test.php [path/to/phar]
```

If no path is provided, it automatically tests the newest `dist/Smarty-v*.phar`. The test creates a Smarty instance and renders a simple template.

## 📋 Troubleshooting

### "Call to undefined class Smarty"
- Make sure you're using `new Smarty\Smarty()` (with namespace) for Smarty 4.x and 5.x
- For Smarty 3.x, use `new Smarty()` (without namespace)

### "Unable to write to compilation directory"
- Ensure `templates_c` directory exists and is writable (chmod 755 or 777)
- Check that your web server has write permissions

### "File not found" errors
- Use absolute paths or paths relative to your PHP file
- Example: `$smarty->setTemplateDir(__DIR__ . '/templates');`

### PHP Version Compatibility
- Smarty 5.x requires PHP 8.1+
- Smarty 4.x requires PHP 7.2+
- Smarty 3.x supports PHP 5.6+

## 🔄 Migration Path to Composer

When you're ready to migrate to proper dependency management:

1. Install Composer on your server
2. Create `composer.json`:
   ```json
   {
       "require": {
           "smarty/smarty": "^5.0"
       }
   }
   ```
3. Run `composer install`
4. Replace `require 'Smarty-vX.X.X.phar';` with `require 'vendor/autoload.php';`
5. Remove the PHAR file

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

**Note:** Smarty itself is licensed under LGPL-3.0. This project only provides packaging scripts.

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📚 Resources

- [Official Smarty Documentation](https://www.smarty.net/docs/en/)
- [Smarty GitHub Repository](https://github.com/smarty-php/smarty)
- [Smarty Forum](https://www.smarty.net/forums/)

---

**Remember:** This is a temporary workaround. For production applications and long-term projects, always use Composer for dependency management.
