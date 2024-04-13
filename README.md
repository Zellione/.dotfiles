# MacOs

## Yabai

To Exclude new windows from tiling look for the window name with following query:

```bash
yabai -m query --windows | jq ".[] | { App: .app, Title: .title }"
```
