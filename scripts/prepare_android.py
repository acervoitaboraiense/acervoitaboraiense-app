#!/usr/bin/env python3
"""Prepara o AndroidManifest.xml: permissão de internet, queries e nome do app."""
import re
from pathlib import Path

manifest_path = Path('android/app/src/main/AndroidManifest.xml')
content = manifest_path.read_text(encoding='utf-8')

if 'android.permission.INTERNET' not in content:
    content = content.replace(
        '<application',
        '<uses-permission android:name="android.permission.INTERNET" />\n    <application',
        1
    )

if '<queries>' not in content:
    queries = (
        '    <queries>\n'
        '        <intent>\n'
        '            <action android:name="android.intent.action.VIEW" />\n'
        '            <data android:scheme="https" />\n'
        '        </intent>\n'
        '        <intent>\n'
        '            <action android:name="android.intent.action.VIEW" />\n'
        '            <data android:scheme="http" />\n'
        '        </intent>\n'
        '        <intent>\n'
        '            <action android:name="android.intent.action.VIEW" />\n'
        '            <data android:scheme="content" />\n'
        '        </intent>\n'
        '        <intent>\n'
        '            <action android:name="android.intent.action.VIEW" />\n'
        '            <data android:scheme="file" />\n'
        '        </intent>\n'
        '    </queries>\n\n'
    )
    content = content.replace('<application', queries + '    <application', 1)

content = re.sub(r'android:label="[^"]*"', 'android:label="Acervo Itaboraiense"', content)
manifest_path.write_text(content, encoding='utf-8')
print('AndroidManifest.xml preparado com sucesso!')
