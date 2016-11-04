## What is Dockerfile Composer

Compose a Dockerfile using snippet(s) of Dockerfile. It allows you to reuse the snippets you wrote before.

## What it solves

There might be duplicated lines across different Dockerfiles, we can extract the common ones into separate snippets and use this script to compose them into a new Dockerfile without copying and pasting.

Here is my use case, I need to create different images for multiple users and I found most of my Dockerfiles came with a pattern:

1. install essential software (git, tar, which)
2. configure services (SSH)
3. install optional software (nginx, pip, gevent, node.js or boost etc.)

For part 2 and 3, the services or software might be varied based on different image requirements but the instructions are identical for the same service/software. So, extract the instructions and put them into a snippet and then cherry-pick snippets I need.

## How to use

Clone git repository
```
https://github.com/blakey22/dockerfile-composer.git
```

Help
```
./compose.sh
```

Compose baseline Dockerfile without any snippets
```
./compose.sh --base
```

Compose Dockerfile from snippets
```
./compose.sh gcc jdk
```

Compose Dockerfile from snippets with designated version
```
./compose.sh pip jdk=7u79-b15
```

## Modify it
The baseline Dockerfile in this repository is CentOS 6.7 with SSH enabled and few software installed (vim, tar and etc.); you may want to change baseline Dockerfile and add/change snippets to fit your needs. This script is based on the structure below to compose a Dockerfile:

```
Dockerfile

    +----------------+
    |     header     |
    +----------------+
    |    snippet A   |
    +----------------+
    |    snippet B   |
    +----------------+
    |    snippet ..  |
    +----------------+    
    |    snippet N   |
    +----------------+
    |     footer     |
    +----------------+
```

Dockerfile:
* header: resources/snippet/_header
* footer: resources/snippet/_footer
* snippetX: resources/snippet/SNIPPET_NAME
