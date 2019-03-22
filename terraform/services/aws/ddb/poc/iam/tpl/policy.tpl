{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${region}:${account_id}:function:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${region}:${account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetRecords",
                "dynamodb:Query"
            ],
            "Resource": [
              "arn:aws:dynamodb:${region}:${account_id}:table/${table_name}",
              "arn:aws:dynamodb:${region}:${account_id}:table/${table_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ],
            "Resource": "arn:aws:dynamodb:${region}:${account_id}:table/${table_name}/stream/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudhsm:CreateLunaClient",
                "cloudhsm:GetClientConfiguration",
                "cloudhsm:DeleteLunaClient",
                "cloudhsm:DescribeLunaClient",
                "cloudhsm:ModifyLunaClient",
                "cloudhsm:DescribeHapg",
                "cloudhsm:ModifyHapg",
                "cloudhsm:GetConfig"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ds:DescribeDirectories",
                "ds:AuthorizeApplication",
                "ds:UnauthorizeApplication"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
}
