# m0veCon - m0leCon Teaser 2025

_Author: Andrea Angelo Raineri <@Rising>_

_Category: rev_

[Source](/src/m0veCon.move)

## Description

i found this on the web, do you understand it? what does this have to do with my NFTs?

## Solution

`m0veCon.mv` is a compiled smart contract for the Aptos Move blockchain, implementing a custom lightweight compression algorithm inspired by [smaz2](https://github.com/antirez/smaz2).

Before being compressed the flag is translated char by char using a random generated key-value table to a sequence of English words.

The Move bytecode can be disassembled with the following command

```bash
aptos move disassemble --bytecode-path /path/to/m0veCon.vm
```

and then the algorithm can be reversed from the disassembled Move-VM code (that follows the pattern of a stack-based VM)

NOTE: To generate the actual attachments released during the CTF the Move compiler v2 was used, which (at the time of writing) makes common Move bytecode decompilers crash due to the unexpected language version. Two possible paths can be followed to overcome the problem and manage to use the available decompilers (thus helping in better reversing the algorithm):

- Patch the language version number in the compiled bytecode
- Patch the decompilers to skip the check on the language version, forcing them to decompile the bytecode (this was the most followed path among the players)

## Exploit

```python
bigrams = "scoligainelespniitrocomolothllchewrtteeaalsadofoaysteessasfiadidctatepenrinoacofhaveiotrshheimicontiiliramemsumiulecreedsosiopdepaieusiaouhondgetteslyowtonsarwetyortaryyoinuntusencanhingdabeiscameotrsoselceliermaviwiagraeiivlatspromdipewaoopletntnaurpouta"
words = ["could", "message", "international", "read", "family", "event", "store", "detail", "system", "version", "last", "national", "need", "link", "travel", "member", "each", "click", "access", "over", "general", "black", "south", "address", "program", "high", "that", "shopping", "said", "download", "forum", "another", "number", "only", "comment", "main", "subject", "data", "site", "following", "hotel", "year", "center", "view", "must", "well", "product", "computer", "internet", "software", "back", "there", "about", "just", "phone", "price", "next", "like", "some", "between", "part", "management", "county", "within", "will", "still", "text", "development", "those", "small", "january", "information", "such", "location", "water", "result", "child", "work", "related", "city", "want", "before", "security", "size", "education", "very", "than", "world", "women", "since", "project", "even", "health", "support", "open", "order", "government", "show", "case", "info", "then", "total", "ebay", "company", "from", "rating", "house", "first", "type", "more", "down", "which", "real", "please", "where", "group", "level", "days", "have", "long", "north", "digital", "profile", "directory", "using", "during", "personal", "white", "business", "report", "them", "most", "area", "home", "item", "video", "care", "many", "privacy", "local", "people", "account", "make", "free", "including", "shipping", "service", "history", "contact", "design", "control", "would", "media", "mail", "sign", "does", "your", "available", "resource", "through", "review", "network", "send", "into", "music", "sport", "life", "here", "guide", "file", "user", "post", "technology", "university", "place", "great", "reserved", "full", "date", "board", "office", "list", "what", "both", "also", "same", "american", "form", "game", "based", "code", "today", "index", "being", "united", "when", "help", "section", "state", "name", "policy", "current", "return", "think", "know", "much", "found", "posted", "under", "special", "page", "this", "news", "student", "good", "used", "book", "online", "right", "public", "rate", "community", "three", "with", "term", "line", "been", "love", "time", "while", "their", "power", "without", "website", "best", "should", "search", "copyright", "research", "other", "class", "previous", "these", "they", "change", "shop", "find", "because", "picture", "after", "school", "were", "made", "take", "check", "email"]

def decompress(c):
    i = 0
    res = bytearray()
    while i < len(c):
        if c[i] & 128 != 0:
            idx = c[i]&127
            res.extend(bigrams[idx*2:idx*2+2].encode())
            i += 1
            continue
        elif 0 < c[i] < 6:
            res.extend(c[i+1:i+1+c[i]])
            i += 1+c[i]
            continue
        elif 5 < c[i] < 9:
            if c[i] == 8: res.append(32)
            res.extend(words[c[i+1]].encode())
            if c[i] == 7: res.append(32)
            i += 2
        else:
            res.append(c[i])
            i += 1
    return res.decode()

key = {'a': 'normal', 'b': 'hunter', 'c': 'attack', 'd': 'vessel', 'e': 'tunnel', 'f': 'method', 'g': 'cancel', 'h': 'format', 'i': 'gravel', 'j': 'origin', 'k': 'rescue', 'l': 'rotate', 'm': 'burden', 'n': 'palace', 'o': 'flower', 'p': 'guitar', 'q': 'ballot', 'r': 'ribbon', 's': 'jacket', 't': 'bishop', 'u': 'hungry', 'v': 'monday', 'w': 'velvet', 'x': 'pillow', 'y': 'insane', 'z': 'purple', '0': 'expert', '1': 'friend', '2': 'medium', '3': 'silent', '4': 'bitter', '5': 'pencil', '6': 'sprint', '7': 'cousin', '8': 'gallon', '9': 'stable', '_': 'proton', '{': 'future', '}': 'wealth'}
out = '0x677588ce2062dfc5702062fcbf6e2066fefc6520a572e96c20a46262b020bd85fa20f2e2b020a96ca97420bd85fa20f2e2b02062fcbf6e206578f591208bc6982066a4a36420c0f0e620e0d9e520f2e2b020a1d2636b20a46262b020d5958420677588ce2062dfc570206578f59120f2e2b020d5958420bd85fa2062dfc57020cf948d'
compressed = bytes.fromhex(out[2:])
decompressed = decompress(compressed)

inverted_key = {v: k for k, v in key.items()}
flag = ""
for w in decompressed.split():
    flag += inverted_key[w]

print(flag)
```
