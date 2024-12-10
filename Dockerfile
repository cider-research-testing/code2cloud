# Use AWS Lambda Python 3.11 base image
FROM public.ecr.aws/lambda/python:3.11

# Copy function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Copy requirements file (we'll create this separately)
COPY requirements.txt .

# Install the function's dependencies
RUN pip install -r requirements.txt

# Set the CMD to your handler
CMD [ "lambda_function.lambda_handler" ]
