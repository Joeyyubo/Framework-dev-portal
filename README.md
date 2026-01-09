# {{ values.portalName }} - Red Hat Developer Hub Instance

{{ values.description }}

## Overview

This is a **complete Red Hat Developer Hub (RHDH) instance** created from a template. This is a fully customizable developer portal framework based on Backstage, **not just a static HTML page**.

This RHDH instance includes:
- **Full Backstage/RHDH framework** with frontend and backend
- **Complete project structure** ready for customization
- **Plugin system** for extending functionality
- **Catalog integration** for managing software components
- **Production-ready** configuration

## Features

- **Complete RHDH Framework**: Full Backstage/RHDH instance with frontend and backend
- **Customizable**: Fully customizable portal with plugins, themes, and configurations
- **Production Ready**: Can be deployed to any environment (Kubernetes, Docker, Cloud)
- **Plugin Support**: Add custom plugins and integrations
- **Catalog Integration**: Manage software components, APIs, and resources

## Getting Started

### Prerequisites

- Node.js 22
- Yarn 3.8.7
- Git

### Installation

1. **Install dependencies:**
   ```bash
   yarn install
   ```

2. **Configure GitHub integration:**
   - Edit `app-config.yaml`
   - Add your GitHub Personal Access Token or configure GitHub App

3. **Start the development server:**
   ```bash
   yarn dev
   ```

4. **Access the portal:**
   - Frontend: http://localhost:3000
   - Backend: http://localhost:7007

## Customization

### Branding

- Edit `app-config.yaml` to change the portal title and organization name
- Customize themes in `packages/app/src/App.tsx`
- Modify navigation in `packages/app/src/components/Root/Root.tsx`

### Plugins

Add plugins to `packages/app/package.json` and configure them in:
- `packages/app/src/App.tsx` - Plugin registration
- `app-config.yaml` - Plugin configuration

### Catalog

- Add catalog entities in `catalog-info.yaml`
- Configure catalog locations in `app-config.yaml`

## Deployment

### 🚀 快速部署（推荐）

想要像 GitHub Pages 一样通过公共 URL 访问你的 RHDH 实例？查看 [DEPLOYMENT.md](./DEPLOYMENT.md) 获取详细部署指南！

**最简单的部署方式：**
1. **Railway**（推荐）- 5 分钟快速部署，完全免费
2. **Render** - 简单易用，免费套餐可用
3. **Fly.io** - 全球 CDN，高性能

### Docker

```bash
docker build -t {{ values.portalName }}-rhdh .
docker run -p 7007:7007 {{ values.portalName }}-rhdh
```

### Kubernetes / Minikube

#### 部署到 Minikube（本地开发）

**快速部署：**
```bash
cd manifests/minikube
./deploy.sh
minikube service your-app-rhdh
```

**详细说明：** 查看 [MINIKUBE_DEPLOYMENT.md](./MINIKUBE_DEPLOYMENT.md)

#### 部署到 Kubernetes 集群

See the `manifests/` directory for Kubernetes deployment configurations.

### Cloud Platforms

This RHDH instance can be deployed to:
- **Railway** - 最简单，推荐用于快速部署
- **Render** - 简单易用
- **Fly.io** - 全球 CDN
- **OpenShift** - 企业级 Kubernetes
- **AWS EKS** - Amazon Kubernetes
- **Azure AKS** - Azure Kubernetes
- **Google GKE** - Google Kubernetes
- Any Kubernetes cluster

📖 **详细部署说明请查看 [DEPLOYMENT.md](./DEPLOYMENT.md)**

## Project Structure

```
.
├── app-config.yaml          # Main configuration file
├── package.json            # Root package.json
├── packages/
│   ├── app/                # Frontend application
│   └── backend/            # Backend service
├── plugins/                # Custom plugins (optional)
└── catalog-info.yaml       # Catalog entity definitions
```

## Configuration

### Portal Settings

- **Title**: {{ values.portalName }} Developer Hub
- **Organization**: {{ values.portalName }} Organization
- **Visibility**: {{ values.portalVisibility }}

### Database

Default: SQLite (file-based, persistent)
- Change to PostgreSQL for production: Edit `app-config.yaml`

## Next Steps

1. **Add plugins**: Install and configure Backstage plugins
2. **Customize UI**: Modify themes, colors, and layouts
3. **Configure integrations**: Set up GitHub, GitLab, or other integrations
4. **Add catalog entities**: Register your software components
5. **Deploy**: Deploy to your preferred platform

## Support

For more information, see:
- [Red Hat Developer Hub Documentation](https://github.com/redhat-developer/rhdh)
- [Backstage Documentation](https://backstage.io/docs)

## About

This RHDH instance was created using the "Create a portal as framework" template.
