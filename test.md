1. [Install ngrok](https://ngrok.com/download)
2. Login to your ngrok account

    2.1. [Get Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)

    2.2. [Create a static domain](https://dashboard.ngrok.com/cloud-edge/domains)

3. Create a ngrok config file somewhere in your system

    ```yml
    authtoken: <your token at step 2.1>
    region: us
    version: 2
    tunnels:
        jenkins:
            addr: 8080 # your local service port
            schemes:
                - https
            host_header: "<your domain at step 2.2>"
            inspect: false
            proto: http
            domain: <your domain at step 2.2>
    ```

4. Install Jenkins as a background service

    ```bash
    ngrok service install --config <path to ngrok config file at step 3>
    ```

5. Done, enjoy your public service domain
