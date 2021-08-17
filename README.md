# bash-functions


## Static Usage

Probably the best way to use these functions is to include this repository into your bash script, and then create an installation script that saves these locally.  This way you aren't dependant on any changes to the files in The interium.

```bash

function import {
  source $(basename $0)/../lib/$1
}
```

## Inspirations
[bash-lib] and [bash-libaries] are two examples of other peoples' bash library setups.  I particularly like [bash-libraries] best practices.  The documenation structure for this comes from, and awk script for documenation generation.

[bash-lib]:https://github.com/aks/bash-lib
[bash-libraries]:https://github.com/juan131/bash-libraries
[shdoc]:https://github.com/reconquest/shdoc
