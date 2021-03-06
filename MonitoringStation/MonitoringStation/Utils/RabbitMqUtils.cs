﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Channels;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using RabbitMQ.Client.Framing.Impl;


namespace MonitoringStation.Utils
{
    public class RabbitMqUtils
    {
        private static readonly string _certPath;
        private static readonly string _certPassword;
        private static readonly string _queueName;
        private static readonly string _userName;
        public static readonly IModel channel;

        static RabbitMqUtils()
        {
            _certPath = ConfigurationManager.AppSettings["CertPath"];

            _certPassword = ConfigurationManager.AppSettings["CertPassword"];

            _queueName = ConfigurationManager.AppSettings["QueueName"];

            _userName = ConfigurationManager.AppSettings["UserName"];

            var factory = new ConnectionFactory()
            {
                HostName = "127.0.0.1",
                AuthMechanisms = new AuthMechanismFactory[] { new ExternalMechanismFactory() },
                UserName = "client1",
                Ssl = new SslOption
                {
                    ServerName = "admin",
                    CertPath = _certPath,
                    CertPassphrase = _certPassword,
                    Enabled = true
                }
            };

            //factory.Ssl.AcceptablePolicyErrors = System.Net.Security.SslPolicyErrors.RemoteCertificateNameMismatch;

            var connection = factory.CreateConnection();
            channel = connection.CreateModel();
        }
        

        public static void Send(byte[] message, string type)
        {
                IBasicProperties props = channel.CreateBasicProperties();

                props.UserId = "client1";
                props.Type = type;

                channel.QueueDeclare(queue: _queueName,
                    durable: false,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                channel.BasicPublish(exchange:"",
                    routingKey:_queueName,
                    basicProperties:props,
                    body:message);
        }

        public static void Receive()
        {
            byte[] message = new byte [1];

                var consumer = new EventingBasicConsumer(channel);

                consumer.Received += (model1, ea) =>
                {
                    switch(ea.BasicProperties.Type)
                    {
                        case "compress":
                            DesktopUtils.ChangeState();
                            Console.WriteLine("Zmiana stanu: kompresja zrzutu ekranu");
                            break;
                        case "block":
                            ProcessUtils.ProcessStateChange(Encoding.ASCII.GetString(ea.Body));
                            Console.WriteLine($"Zmiana stanu: {Encoding.ASCII.GetString(ea.Body)}");
                            break;
                    }
                };

                channel.BasicConsume(queue: _userName,
                    autoAck: true,
                    consumer: consumer);

        }


    }
}
