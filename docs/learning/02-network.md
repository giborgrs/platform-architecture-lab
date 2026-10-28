# 02: Network layer

- **What I built:** AWS VPC (3 AZs x public/private/data subnets, IGW, NAT, S3 endpoint) and an
  Azure VNet (AKS and data subnets, NSGs, NAT gateway), each as a module plus a `10-network` root.
- **Why it is designed this way:** see ADR-0006. The state is its own layer (ADR-0003) so cluster
  work can never modify the network.
- **Questions to answer yourself:**
  - What makes a subnet "public" in AWS? (Hint: look at its route table, not its name.)
  - Why is the private subnet a /20 but the public one a /24?
  - Why does the data route table have no `0.0.0.0/0` route?
  - In Azure, what plays the role of an AWS security group? Of a route table?
- **Break it on purpose:** delete the `aws_route.private_nat` route in the console, then try to pull
  a public image from a private subnet. Re-run `terraform plan` and watch it detect the drift.
- **Interview question this answers:** "Design the network for a multi-AZ Kubernetes platform and
  explain what is public, what is private, and why."
