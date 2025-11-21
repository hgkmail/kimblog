---
title: 装饰器模式和切面编程
date: 2025-11-21 16:15:52
categories:
  - 编程💻
tags:
  - 设计模式
  - 切面
---

装饰器模式和切面编程都用于"增强"现有功能，但它们的理念、实现方式和应用场景有显著区别。

<!--more-->

## 📊 核心区别对比

| 维度 | **装饰器模式** | **面向切面编程** |
| :--- | :--- | :--- |
| **核心关系** | **"包装"关系** - 静态的层次结构 | **"横切"关系** - 动态的交叉关注点 |
| **设计层面** | **代码级别**的结构型设计模式 | **架构级别**的编程范式 |
| **耦合度** | **紧耦合** - 需要知道被装饰的接口 | **极低耦合** - 对业务代码完全透明 |
| **关注点** | 单个**对象**的功能增强 | 多个**方法**的横切关注点 |
| **实现方式** | 编译时**静态包装** | 运行时**动态织入** |
| **使用方式** | 需要**显式**创建装饰器并包装目标对象 | **声明式** - 通过注解或配置自动应用 |

---

## 🔍 详细解析与代码示例

### 1. 装饰器模式：显式的层次包装

装饰器模式通过**实现相同接口 + 组合**的方式，在**编译时**构建一层层的包装结构。

```java
// 1. 基础接口
public interface DataService {
    String processData(String input);
}

// 2. 具体实现
public class BasicDataService implements DataService {
    @Override
    public String processData(String input) {
        return "Processed: " + input;
    }
}

// 3. 装饰器基类（实现相同接口）
public abstract class DataServiceDecorator implements DataService {
    protected DataService wrapped;
    
    public DataServiceDecorator(DataService wrapped) {
        this.wrapped = wrapped; // 必须知道要包装什么
    }
    
    @Override
    public String processData(String input) {
        return wrapped.processData(input);
    }
}

// 4. 具体装饰器 - 加密功能
public class EncryptionDecorator extends DataServiceDecorator {
    public EncryptionDecorator(DataService wrapped) {
        super(wrapped);
    }
    
    @Override
    public String processData(String input) {
        String result = super.processData(input);
        return "🔒 Encrypted: " + result; // 增强功能
    }
}

// 5. 具体装饰器 - 压缩功能  
public class CompressionDecorator extends DataServiceDecorator {
    public CompressionDecorator(DataService wrapped) {
        super(wrapped);
    }
    
    @Override
    public String processData(String input) {
        String result = super.processData(input);
        return "🗜️ Compressed: " + result; // 增强功能
    }
}

// 使用方式：必须显式包装
public class Client {
    public static void main(String[] args) {
        // 原始对象
        DataService service = new BasicDataService();
        
        // 层层包装 - 编译时确定结构
        DataService encryptedService = new EncryptionDecorator(service);
        DataService compressedEncryptedService = 
            new CompressionDecorator(encryptedService);
        
        String result = compressedEncryptedService.processData("hello");
        // 输出: 🗜️ Compressed: 🔒 Encrypted: Processed: hello
    }
}
```

**装饰器模式的特点**：
- ✅ **精细控制**：可以精确控制装饰的顺序和范围
- ✅ **类型安全**：编译时检查，IDE支持良好
- ❌ **紧耦合**：必须知道要装饰的具体接口
- ❌ **代码侵入**：需要在客户端代码中显式包装

### 2. 面向切面编程：声明式的横切增强

AOP通过**动态代理/字节码增强**在**运行时**自动织入横切逻辑。

```java
// 1. 业务类 - 完全纯净，不知道切面的存在
@Service
public class UserService {
    public void createUser(String username) {
        System.out.println("Creating user: " + username);
        // 纯业务逻辑，没有任何日志、事务代码
    }
    
    public void deleteUser(Long id) {
        System.out.println("Deleting user: " + id);
        // 纯业务逻辑
    }
}

@Service  
public class ProductService {
    public void addProduct(String productName) {
        System.out.println("Adding product: " + productName);
    }
}

// 2. 切面 - 集中处理横切关注点
@Aspect
@Component
public class LoggingAspect {
    
    // 切入点：匹配多个类的方法
    @Pointcut("execution(* com.example.service.*.*(..))")
    public void serviceMethods() {}
    
    // 前置通知 - 自动织入到匹配的方法
    @Before("serviceMethods()")
    public void logMethodStart(JoinPoint joinPoint) {
        System.out.println("📝 [AOP] Starting: " + 
            joinPoint.getSignature().getName());
    }
    
    // 环绕通知 - 性能监控
    @Around("serviceMethods()")
    public Object measurePerformance(ProceedingJoinPoint pjp) throws Throwable {
        long start = System.currentTimeMillis();
        try {
            return pjp.proceed(); // 继续执行原方法
        } finally {
            long duration = System.currentTimeMillis() - start;
            System.out.println("⏱️ [AOP] Method took: " + duration + "ms");
        }
    }
}

// 使用方式：业务代码完全不变
@Service
public class ApplicationService {
    @Autowired
    private UserService userService;
    @Autowired
    private ProductService productService;
    
    public void runBusinessProcess() {
        userService.createUser("Alice");  // 自动织入日志和性能监控
        productService.addProduct("Laptop"); // 自动织入日志和性能监控
    }
}

// 输出：
// 📝 [AOP] Starting: createUser
// Creating user: Alice  
// ⏱️ [AOP] Method took: 5ms
// 📝 [AOP] Starting: addProduct
// Adding product: Laptop
// ⏱️ [AOP] Method took: 3ms
```

**AOP的特点**：
- ✅ **完全解耦**：业务代码不知道切面的存在
- ✅ **集中管理**：横切逻辑在一个地方维护
- ✅ **动态性**：可以在运行时通过配置改变织入逻辑
- ❌ **调试困难**：调用栈变得复杂
- ❌ **过度使用可能导致"魔法"**：流程不直观

---

## 🔗 联系与相似之处

尽管有诸多不同，但它们都共享一些共同目标：

1. **都遵循开闭原则**：不修改现有代码的情况下扩展功能
2. **都用于功能增强**：为主逻辑添加额外的能力
3. **都提倡关注点分离**：将核心逻辑与辅助逻辑分开

---

## 🎯 如何选择：场景驱动

### 选择 **装饰器模式** 当：
- 你需要**精细控制**装饰的顺序和组合
- 增强逻辑与**特定接口紧密相关**
- 希望在**编译时**确定所有增强关系
- 需要**类型安全**和IDE的良好支持
- 例子：Java I/O流体系 `BufferedInputStream(new FileInputStream(...))`

### 选择 **面向切面** 当：
- 你需要为**多个不相关的类**添加相同功能
- 增强逻辑是**真正的横切关注点**（日志、事务、安全等）
- 希望**业务代码保持纯净**，不受技术关注点污染
- 需要**运行时灵活性**，通过配置决定是否应用增强
- 例子：Spring的事务管理、统一日志、性能监控

### 💡 实践建议

在实际项目中，它们经常**协同工作**：
- 使用**装饰器模式**处理**业务维度**的功能组合
- 使用**AOP**处理**技术维度**的横切关注点

```java
// 业务维度的装饰器
PriceCalculator decoratedCalculator = new DiscountDecorator(
    new TaxDecorator(new BasicPriceCalculator())
);

// 技术维度的AOP自动处理：日志、事务、性能监控等
// @Transactional
// public Order createOrder() { ... } - AOP自动管理事务
```

这样既保持了业务逻辑的清晰性，又获得了横切关注点的自动化管理。
