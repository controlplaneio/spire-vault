# K8S 1.21+ issues

Spire > v1.1.0 has [issues](https://github.com/spiffe/spire/issues/2578) on K8S 1.21+.

Until the next release you need to take the following steps to run this example.

1. Clone the [Spire](https://github.com/spiffe/spire) repo
2. Build the Spire Agent image `make spire-agent-image` in the cloned repo
3. Push the image to the kind cluster `make load-image-spire-agent`
4. Substitute `make make deploy-spire-server deploy-spire-agent-latest-local` for `make deploy-spire`
