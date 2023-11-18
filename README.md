# Chrome OS Systemd Patches

This repository contains a few patches to systemd which allow it to run on Chrome OS kernels. 

There is also a script which will automatically download systemd, apply the patches, and build the binary packages for Debian.

To build systemd with these patches, run `./build.sh`.

To build a Debian repository containing the modified systemd packages, run `./build_repo.sh`.

## Copyright:
Credit for fixing the original bug in systemd goes to [@r58playz](https://github.com/r58Playz/).

This repository is licensed under the [GNU LGPL v2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt).

```
ading2210/chromeos-systemd: Patched systemd for Chrome OS kernels
Copyright (C) 2023 ading2210

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
```