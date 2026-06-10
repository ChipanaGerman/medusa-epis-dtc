
# Requisitos Técnicos: Dashboard de Analíticas

## 1. OBJETIVO GENERAL

El objetivo de este dashboard es proporcionar una visión centralizada y en tiempo real del rendimiento del e-commerce. Permitirá a los administradores y gerentes de la tienda tomar decisiones informadas basadas en datos, identificando tendencias de ventas, comportamiento del cliente y eficiencia operativa.

## 2. REQUISITOS DE DATOS

| Característica | Descripción |
| :--- | :--- |
| **Fuentes de Datos** | La única fuente de datos será la base de datos **PostgreSQL** (`medusa-store`) del proyecto. Se consultarán principalmente las tablas de `order`, `customer`, `product`, y `line_item`. |
| **Volumen Estimado** | Se estima un volumen medio, con capacidad para escalar a cientos de miles de registros en las tablas principales sin degradar el rendimiento. |
| **Tipo de Consulta** | - **Batch (Lotes):** Para métricas históricas y agregadas (ej. ventas del último mes), se ejecutarán trabajos nocturnos para pre-calcular y almacenar los resultados en tablas de resumen o en la caché de Redis. <br> - **Tiempo Real:** Para métricas operativas (ej. ventas de hoy, usuarios activos), las consultas se realizarán directamente contra la base de datos, optimizadas para una respuesta rápida. |

## 3. REQUISITOS FUNCIONALES CLAVE

El dashboard debe presentar las siguientes métricas y visualizaciones:

- **KPIs Principales (Single-Value):**
    - **Ingresos Totales (GTV):** Suma total de ventas.
    - **Número de Pedidos:** Conteo total de pedidos completados.
    - **Ticket Promedio (AOV):** Ingresos totales / Número de pedidos.
    - **Nuevos Clientes:** Conteo de clientes creados en el período seleccionado.

- **Gráficos de Línea (Tendencias):**
    - **Ventas a lo largo del tiempo:** Un gráfico que muestre los ingresos diarios, semanales o mensuales.
    - **Pedidos a lo largo del tiempo:** Gráfico con el número de pedidos en el tiempo.

- **Tablas de Rendimiento:**
    - **Top 5 Productos Más Vendidos:** Tabla con `Producto`, `Cantidad Vendida` y `Total Ingresos`.
    - **Top 5 Clientes con Mayor Gasto:** Tabla con `Cliente`, `Número de Pedidos` y `Gasto Total`.

- **Filtros Interactivos:**
    - Un selector de rango de fechas global para filtrar todas las métricas del dashboard (ej. "Hoy", "Últimos 7 días", "Este mes", "Rango personalizado").

## 4. REQUISITOS NO FUNCIONALES

| Requisito | Meta | Estrategia |
| :--- | :--- | :--- |
| **Tiempo de Carga Inicial** | < 3 segundos | Carga inicial de la página con datos cacheados o pre-calculados. |
| **Tiempo de Carga de Gráfico** | < 1.5 segundos | Consultas optimizadas y uso de la caché de Redis para datos frecuentemente accedidos. |
| **Concurrencia de Usuarios** | Soportar hasta 50 usuarios administradores concurrentes sin degradación notable. | Escalado horizontal del backend de Medusa y optimización de la pool de conexiones de PostgreSQL. |
| **Estrategia de Caché** | Redis | Se utilizará **Redis**, que ya forma parte del stack, para cachear los resultados de las consultas más pesadas y los datos pre-calculados. La clave de caché incluirá los parámetros del filtro (ej. `dashboard:sales:2023-10-01:2023-10-31`). |

## 5. SEGURIDAD Y LOGS

- **Control de Acceso Basado en Roles (RBAC):**
    - **Rol `admin`:** Acceso completo a todas las métricas y filtros del dashboard.
    - **Rol `member` (o similar):** Acceso de solo lectura al dashboard, sin posibilidad de exportar datos.
    - Se debe extender el modelo de usuarios de Medusa para implementar estos roles si no existen.

- **Registro de Eventos (Logging):**
    - Se deben registrar los siguientes eventos para auditoría y depuración:
        - `dashboard_access`: Quién accedió al dashboard y cuándo.
        - `dashboard_filter_change`: Qué filtros aplicó un usuario.
        - `dashboard_export`: Si se exportaron datos (si se implementa esta función).

## 6. COMPONENTES FRONTEND RECOMENDADOS

Dado que el stack frontend utiliza **React (Next.js y Vite)**, se recomiendan las siguientes librerías de gráficos por su compatibilidad y facilidad de integración:

| Librería | Ventajas | Consideraciones |
| :--- | :--- | :--- |
| **Recharts** | API declarativa y muy popular en el ecosistema React. Altamente personalizable. | Puede ser pesada si se importan muchos componentes. |
| **Tremor** | Diseñada para dashboards, ofrece componentes de UI (gráficos, KPIs, tablas) listos para usar y con un diseño excelente. Ideal para construir rápido. | Menos personalizable que Recharts, pero perfecta para un MVP. |
| **Chart.js** | Ligera y con buen rendimiento. Fácil de empezar. | Requiere un wrapper de React (`react-chartjs-2`) para una integración más limpia. |

**Recomendación:** Empezar con **Tremor** para construir rápidamente un dashboard funcional y estéticamente agradable, aprovechando sus componentes pre-construidos. Si se requiere personalización extrema a futuro, se puede migrar a **Recharts**.

### Ejemplos de implementación con Tremor:

A continuación se muestran ejemplos de cómo se podrían implementar los componentes clave del dashboard utilizando la librería `tremor/react`.

#### 1. Tarjeta de KPI (Métrica Principal)

Para mostrar métricas clave como "Ingresos Totales" o "Número de Pedidos".

```jsx
import { Card, Metric, Text } from '@tremor/react';

function KpiCard({ title, metric }) {
  return (
    <Card>
      <Text>{title}</Text>
      <Metric>{metric}</Metric>
    </Card>
  );
}
```

#### 2. Gráfico de Tendencias (Ventas a lo largo del tiempo)

Para visualizar la evolución de las ventas diarias, semanales o mensuales.

```jsx
import { Card, Title, AreaChart } from '@tremor/react';

const chartdata = [
  { date: 'Ene 22', Sales: 2890 },
  { date: 'Feb 22', Sales: 2756 },
  // ... más datos
  { date: 'Oct 23', Sales: 2833 },
];

function SalesChart() {
  return (
    <Card>
      <Title>Ventas a lo largo del tiempo</Title>
      <AreaChart
        className="mt-6"
        data={chartdata}
        index="date"
        categories={['Sales']}
        colors={['blue']}
        yAxisWidth={40}
      />
    </Card>
  );
}
```

#### 3. Tabla de Rendimiento (Top Productos)

Para listar los productos más vendidos con sus respectivas métricas.

```jsx
import {
  Card,
  Table,
  TableHead,
  TableRow,
  TableHeaderCell,
  TableBody,
  TableCell,
  Text,
  Title,
} from '@tremor/react';

const products = [
  { name: 'Producto A', quantity: 123, revenue: 'S/ 4,500' },
  { name: 'Producto B', quantity: 98, revenue: 'S/ 3,200' },
  // ... más productos
];

function TopProductsTable() {
  return (
    <Card>
      <Title>Top 5 Productos Más Vendidos</Title>
      <Table className="mt-5">
        <TableHead>
          <TableRow>
            <TableHeaderCell>Producto</TableHeaderCell>
            <TableHeaderCell>Cantidad Vendida</TableHeaderCell>
            <TableHeaderCell>Total Ingresos</TableHeaderCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {products.map((item) => (
            <TableRow key={item.name}>
              <TableCell>{item.name}</TableCell>
              <TableCell>
                <Text>{item.quantity}</Text>
              </TableCell>
              <TableCell>
                <Text>{item.revenue}</Text>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </Card>
  );
}
```
