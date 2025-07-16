# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Kibernum Ecommerce API',
        version: 'v1',
        description: 'A comprehensive ecommerce API with product management, customer tracking, purchase processing, and administrative features with JWT authentication and audit logging.',
        contact: {
          name: 'Kibernum Development Team'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.kibernum-ecommerce.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      },
      security: [
        {
          bearerAuth: []
        }
      ]
    }
  }
  config.swagger_format = :yaml
end
