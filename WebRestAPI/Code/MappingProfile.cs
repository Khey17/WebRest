using System;
using AutoMapper;
// DO NOT FORGET TO UNCOMMENT THIS LINE

using WebRest.EF.Models;

namespace WebRestAPI.Code;

 public class MappingProfile : Profile {
     public MappingProfile() {
         // Add as many of these lines as you need to map your objects
         CreateMap<Customer, Customer>();
         CreateMap<Address, Address>();
         CreateMap<AddressType, AddressType>();
         CreateMap<CustomerAddress, CustomerAddress>();
         CreateMap<Gender, Gender>();
         CreateMap<OrderState, OrderState>();
         CreateMap<OrderStatus, OrderStatus>();
         CreateMap<Order, Order>();
         CreateMap<OrdersLine, OrdersLine>();
         CreateMap<Product, Product>();
         CreateMap<ProductPrice, ProductPrice>();
     }
 }
