Install and run AFP-Perl on your Raspberry Pi.

## Installation

Run the installation script:

```
bash install-afp-perl.sh
```

## Testing AFP Discovery

You can test AFP discovery using the `discover-afp.pl` script. Run it like:

```
perl discover-afp.pl
```

To view available options, use:

```
perl discover-afp.pl --help
```

## Script Details

### NAME
`discover-afp.pl` - Discover and display AFP (Apple Filing Protocol) service information.

### SYNOPSIS
```
discover-afp.pl [options]
```

#### Options:
- `-f, --fields <field1,field2,...>`: Specify fields to display (comma-separated).
- `-h, --help`: Display this help message.

### DESCRIPTION
This script discovers AFP services over TCP (mDNS) and optionally over AppleTalk (if supported). It displays information about the discovered services based on the specified fields.

### FIELDS
The following fields can be displayed:
- `ServerName`: The name of the AFP server.
- `UTF8ServerName`: The UTF-8 encoded name of the AFP server.
- `MachineType`: The type of machine running the AFP server.
- `AFPVersions`: The supported AFP versions.
- `UAMs`: The User Authentication Methods supported by the server.
- `NetworkAddresses`: The network addresses of the server.
- `VolumeIcon`: The icon associated with the server (if available).

### EXAMPLES

1. **Display default fields for all discovered AFP services:**

```
discover-afp.pl
```

2. **Display specific fields (ServerName, MachineType, AFPVersions):**

```
discover-afp.pl --fields ServerName,MachineType,AFPVersions
```

3. **Display help message:**

```
discover-afp.pl --help
```

```
