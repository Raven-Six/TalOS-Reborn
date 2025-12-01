# Environment Variables Configuration

This project uses environment variables to configure server and frontend settings.

## Setup

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to customize your configuration

## Available Environment Variables

### Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3003` | The port the backend server will run on |
| `HOST` | `0.0.0.0` | The host/IP address the server will bind to |

### Frontend Configuration (Vite Dev Server)

| Variable | Default | Description |
|----------|---------|-------------|
| `VITE_PORT` | `5173` | The port the frontend development server will run on |
| `VITE_HOST` | `0.0.0.0` | The host/IP address for the Vite dev server |

## Host Configuration Options

### `HOST` Variable

- **`0.0.0.0`** (default) - Binds to all network interfaces. Server is accessible from:
  - localhost (127.0.0.1)
  - Your local network IP (e.g., 192.168.1.100)
  - External networks (if firewall allows)

- **`127.0.0.1` or `localhost`** - Only allows local connections. Server is only accessible from the same machine.

- **Specific IP** (e.g., `192.168.1.100`) - Binds to a specific network interface.

## Examples

### Example 1: Default Configuration (All Interfaces)
```env
PORT=3003
HOST=0.0.0.0
VITE_PORT=5173
VITE_HOST=0.0.0.0
```
Access: `http://localhost:3003` or `http://<your-ip>:3003`

### Example 2: Local Only
```env
PORT=3003
HOST=127.0.0.1
VITE_PORT=5173
VITE_HOST=127.0.0.1
```
Access: `http://localhost:3003` only

### Example 3: Custom Port
```env
PORT=8080
HOST=0.0.0.0
VITE_PORT=5173
VITE_HOST=0.0.0.0
```
Access: `http://localhost:8080` or `http://<your-ip>:8080`

### Example 4: Specific Network Interface
```env
PORT=3003
HOST=192.168.1.100
VITE_PORT=5173
VITE_HOST=192.168.1.100
```
Access: `http://192.168.1.100:3003`

## Notes

- Changes to `.env` require restarting the server
- The `.env` file is ignored by git (see `.gitignore`)
- Always use `.env.example` as a template for new environments
- For production deployments, set environment variables directly in your hosting platform
