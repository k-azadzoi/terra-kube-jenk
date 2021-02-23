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

resource "kubernetes_deployment" "demoapp" {
  metadata {
    name      = "demoapp"
    labels = {
        App = "demoapp"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "MyDemoApp"
      }
    }
    template {
      metadata {
        labels = {
          App = "MyDemoApp"
        }
      }
      spec {
        container {
          image = "kcharette/ec2-pipeline:58"
          name  = "example"
          port {
            container_port = 80
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
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
  }
  spec {
    selector = {
      App = kubernetes_deployment.demoapp.spec.0.template.0.metadata.0.labels.App
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
  }
}