import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("resume-visitor-counter")


def lambda_handler(event, context):
    response = table.update_item(
        Key={
            "id": "visitors"
        },
        UpdateExpression="ADD viewCount :increment",
        ExpressionAttributeValues={
            ":increment": 1
        },
        ReturnValues="UPDATED_NEW"
    )

    count = int(response["Attributes"]["viewCount"])

    return {
        "statusCode": 200,
        "body": str(count)
    }