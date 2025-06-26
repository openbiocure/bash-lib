
## Installation

```bash
# Clone the repository
git clone <repository-url>
cd bash-lib

# Install dependencies
make install-deps

# Install bash-lib
make install
```

## Usage

```bash
# Source the library
export BASH__PATH="/path/to/bash-lib"
source core/init.sh

# Import a module
import directory
import http
import math

# Use the functions
directory.create /tmp/test
http.get https://api.example.com
math.add 5 3
```

## Modules


## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your module or improvements
4. Write tests for your changes
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Generated automatically by manual.sh*

