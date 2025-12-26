# Git Config Information

## GPG Procedure

For when a key expires and a new one needs to be created.

### Generate a Key (no passphrase, because it is annoying)

```
gpg --full-generate-key
```


### List Keys

```
gpg --list-keys
```

### Export Public key

```
gpg --armor --export <key-id>
```

### Delete Public Key

```
gpg --delete-key <key-id>
```

### Delete Secret Key

```
gpg --delete-secret-key <key-id>
```
