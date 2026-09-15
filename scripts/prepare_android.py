#!/usr/bin/env python3
"""Prepara o AndroidManifest.xml e os arquivos de build do Android."""
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
print('AndroidManifest.xml preparado.')

gradle_path = None
for name in ['build.gradle', 'build.gradle.kts']:
    p = Path('android/app') / name
    if p.exists():
        gradle_path = p
        break

if gradle_path:
    g_content = gradle_path.read_text(encoding='utf-8')
    g_content = re.sub(r'compileSdk\s*=\s*\d+', 'compileSdk = 35', g_content)
    g_content = re.sub(r'compileSdkVersion\s+\d+', 'compileSdkVersion 35', g_content)
    gradle_path.write_text(g_content, encoding='utf-8')
    print(f'{gradle_path} atualizado com compileSdk = 35.')

root_gradle_path = None
for name in ['build.gradle', 'build.gradle.kts']:
    p = Path('android') / name
    if p.exists():
        root_gradle_path = p
        break

if root_gradle_path:
    rg_content = root_gradle_path.read_text(encoding='utf-8')
    rg_content = re.sub(
        r'com\.android\.tools\.build:gradle:\d+\.\d+\.\d+',
        'com.android.tools.build:gradle:8.6.0',
        rg_content
    )
    rg_content = re.sub(
        r'id\("com\.android\.application"\)\s+version\s+"[^"]+"\s+apply\s+false',
        'id("com.android.application") version "8.6.0" apply false',
        rg_content
    )
    root_gradle_path.write_text(rg_content, encoding='utf-8')
    print('Versão do AGP atualizada para 8.6.0.')

wrapper_path = Path('android/gradle/wrapper/gradle-wrapper.properties')
if wrapper_path.exists():
    w_content = wrapper_path.read_text(encoding='utf-8')
    w_content = re.sub(
        r'distributionUrl=.*',
        'distributionUrl=https\\://services.gradle.org/distributions/gradle-8.7-all.zip',
        w_content
    )
    wrapper_path.write_text(w_content, encoding='utf-8')
    print('Gradle atualizado para 8.7.')

print('Todos os arquivos de build foram preparados!')
