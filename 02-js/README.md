# MINECRAFT CASTLE BUILDER ADD-ON

## Setup

Windows:
```pwsh
docker build -t minecraft-builder .
docker run --rm -v "${env:APPDATA}\Minecraft Bedrock\Users\Shared\games\com.mojang\development_behavior_packs\CastleScript:/out" minecraft-builder
```