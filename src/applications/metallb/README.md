# MetalLB: Bare-Metal Load-Balancer for Kubernetes


## Service Description


<!--description-start-->
MetalLB is a load-balancer implementation for bare-metal Kubernetes clusters. It allows services of `type: LoadBalancer` to work in environments without external cloud providers. This provides an easy way to expose services externally without relying on cloud-specific load balancing solutions.
<!--description-end-->

<!--header-start-->
**Namespace:** `metallb-system`  
**Deployment:**  
**Terraform Provider:** 
**Web:** [metallb.io](https://metallb.io/)  
<!--header-end-->

## Key Features

*   **Layer 2 mode (ARP/NDP):** Operates at the data link layer, making the Kubernetes nodes respond to ARP requests for service IPs. Simple to set up but limited to a single subnet.
*   **BGP mode:** Uses the Border Gateway Protocol (BGP) to advertise service IPs to the network. More complex to configure but allows load balancing across multiple subnets and provides better failover capabilities.
*   **IP address management:** Manages IP addresses from a configured pool, automatically assigning them to services.
*   **High availability:** Can be configured for high availability to prevent single points of failure.

## Use Cases

*   Exposing web applications running on a bare-metal Kubernetes cluster.
*   Providing external access to databases or other backend services.
*   Creating highly available services that can withstand node failures.

## Technical Details

MetalLB runs as a set of pods within the Kubernetes cluster. It integrates with the Kubernetes service controller to watch for services of `type: LoadBalancer`. When such a service is created, MetalLB assigns an IP address from its pool and configures the network accordingly (either via ARP/NDP or BGP).

## Prerequisites

*   A running Kubernetes cluster.
*   A pool of IP addresses that MetalLB can use.
*   For BGP mode: A BGP router in the network.

## Benefits

*   **Simplicity:** Easy to deploy and configure, especially in Layer 2 mode.
*   **Cost-effective:** Eliminates the need for expensive external load balancers.
*   **Flexibility:** Supports different networking configurations.
*   **Open Source:** Community-driven and actively maintained.

## Limitations

*   Layer 2 mode is limited to a single subnet.
*   BGP mode requires a BGP router and some networking knowledge.

## Further Information

*   [MetalLB Documentation](https://metallb.universe.tf/)