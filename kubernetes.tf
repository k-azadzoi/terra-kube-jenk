terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.0.2"
    }
  }
}

provider "kubernetes" {
    config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "demoapp" {
  metadata {
    name = "demoapp"
  }
}

resource "kubernetes_deployment" "demoapp" {
  metadata {
    name      = "demoapp"
    namespace = kubernetes_namespace.demoapp.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyDemoApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyDemoApp"
        }
      }
      spec {
        container {
          image = "kcharette/sba-python:v1"
          name  = "demoapp"
          port {
            container_port = 80
          }
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "demoapp" {
  metadata {
    name      = "demoapp"
    namespace = kubernetes_namespace.demoapp.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.demoapp.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
  }
}