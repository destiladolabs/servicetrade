#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of the ServiceTrade Job API
# This file demonstrates the Job API functions implemented for the ServiceTrade Ruby gem

require_relative '../lib/servicetrade'

# Configure the client
ServiceTrade.configure do |config|
  config.username = ENV['SERVICETRADE_USERNAME'] || 'your_username'
  config.password = ENV['SERVICETRADE_PASSWORD'] || 'your_password'
end

begin
  puts "ServiceTrade Job API Examples"
  puts "=" * 40

  # List all jobs (defaults to status='scheduled')
  puts "\n1. List all scheduled jobs:"
  jobs = ServiceTrade::Job.list
  puts "Found #{jobs.length} scheduled jobs"

  # List jobs with specific filters
  puts "\n2. List completed jobs:"
  completed_jobs = ServiceTrade::Job.list(status: 'completed')
  puts "Found #{completed_jobs.length} completed jobs"

  # List jobs for a specific vendor
  puts "\n3. List jobs for vendor ID 123:"
  vendor_jobs = ServiceTrade::Job.by_vendor(123)
  puts "Found #{vendor_jobs.length} jobs for vendor 123"

  # Find a specific job by ID
  puts "\n4. Find job by ID:"
  job = ServiceTrade::Job.find(12345) # Replace with actual job ID
  puts "Job: #{job.name} (Status: #{job.status})"
  puts "Description: #{job.description}" if job.description

  # Create a new job
  puts "\n5. Create a new job:"
  new_job = ServiceTrade::Job.create(
    custom_name: 'API Test Job',
    location_id: 456,
    type: 'repair',
    description: 'Test job created via API',
    vendor_id: 789
  )
  puts "Created job: #{new_job.name} (ID: #{new_job.id})"

  # Update a job
  puts "\n6. Update job status:"
  updated_job = ServiceTrade::Job.update(new_job.id, {
    status: 'completed',
    percent_complete: 100
  })
  puts "Updated job status to: #{updated_job.status}"

  # Search jobs around a location
  puts "\n7. Search jobs within 50 miles of coordinates:"
  nearby_jobs = ServiceTrade::Job.around_location(35.7796, -78.6382, 50)
  puts "Found #{nearby_jobs.length} jobs within 50 miles"

  # Search jobs due within a date range
  puts "\n8. Search jobs due in the next 30 days:"
  start_time = Time.now.to_i
  end_time = (Time.now + 30 * 24 * 60 * 60).to_i # 30 days from now
  due_jobs = ServiceTrade::Job.due_between(start_time, end_time)
  puts "Found #{due_jobs.length} jobs due in the next 30 days"

  # Using convenience methods
  puts "\n9. Using status convenience methods:"
  puts "Job #{new_job.id} completed?: #{new_job.completed?}"
  puts "Job #{new_job.id} scheduled?: #{new_job.scheduled?}"

  # Add task responses to a job
  puts "\n10. Add task responses to job:"
  task_responses = [
    {
      task_instance_id: 123,
      response: ['Yes, task completed'],
      response_user_id: 456
    },
    {
      task_instance_id: 124,
      response: ['2023-12-25'] # Date response
    }
  ]
  
  response_result = new_job.add_task_responses(task_responses)
  puts "Added #{response_result['responseCount']} task responses"

rescue ServiceTrade::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
  puts "Please check your username and password"
rescue ServiceTrade::ApiError => e
  puts "API error: #{e.message}"
rescue => e
  puts "Unexpected error: #{e.message}"
  puts "This might indicate a configuration or network issue"
end

puts "\n" + "=" * 40
puts "Example completed. Check the ServiceTrade dashboard to see created/modified jobs."