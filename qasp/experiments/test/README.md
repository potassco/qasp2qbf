# Usage

Test all domain:
```bash
$ python -m unittest
```

Test only conformant problems:
```bash
$ python -m unittest test.TestConformant
```

Test only conditional problems:
```bash
$ python -m unittest test.TestConformant
```

You can also run a single domain. For example, to test the btuc domain run:
```bash
$ python -m unittest test.TestConformant.test_btuc
```
