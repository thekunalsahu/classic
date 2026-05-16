import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace Colors.cyanAccent.withOpacity(...) to Color(0xFF39FF14).withOpacity(...)
content = content.replace("Colors.cyanAccent.withOpacity", "Color(0xFF39FF14).withOpacity")

# Replace Colors.cyanAccent to const Color(0xFF39FF14) where it's safe, or just Color(0xFF39FF14)
# To be completely safe and avoid syntax errors with `const const Color` or non-constant contexts,
# we just use Color(0xFF39FF14). It might cause a few "prefer_const_constructors" lints, but it will definitely compile and work correctly.
content = content.replace("Colors.cyanAccent", "Color(0xFF39FF14)")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
