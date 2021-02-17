def lambda_handler(event, context):
    response = event['Records'][0]['cf']['response']
    request = event['Records'][0]['cf']['request']
    host = event['Records'][0]['cf']['request']['headers']['host'][0]['value']

    print(f'Request is {request}')
    fallback_url = 'http://prod.cdn.bamsey.net' + request['uri']

    # This function updates the HTTP status code in the response to 302, to redirect to another
    # url. Note the following:
    # 1. The function is triggered in an origin response
    # 2. The response status from the origin server is an error status code (4xx)
    # 3. The update only occurs if the function name is prefixed with the environment beta

    if 400 <= int(response['status']) <= 499 and host.startswith("beta"):
        response['status'] = 302
        response['statusDescription'] = 'Found'

        # Drop the body as it is not required for redirects
        response['body'] = ''
        response['headers']['location'] = [{'key': 'Location', 'value': fallback_url}]

    return response
