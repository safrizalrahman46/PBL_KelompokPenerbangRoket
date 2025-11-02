@extends('layouts.app')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>Table Order</h4>
        <button class="btn btn-success">+ Create New</button>
    </div>

    <div class="input-group mb-3">
        <input type="text" class="form-control" placeholder="Search">
        <button class="btn btn-outline-secondary">Filter</button>
        <button class="btn btn-outline-secondary">Sort By</button>
    </div>

    <table class="table table-bordered bg-white shadow-sm">
        <thead>
            <tr>
                <th>No</th>
                <th>Order Code</th>
                <th>Date</th>
                <th>Customer</th>
                <th>Total</th>
                <th>Payment Status</th>
                <th>Items</th>
                <th>Order Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @for($i = 1; $i <= 6; $i++)
            <tr>
                <td>{{ $i }}</td>
                <td>#09093231</td>
                <td>09/12/2025</td>
                <td>{{ ['Sujono', 'Kartolo', 'Baksu', 'KIRUN', 'Suki', 'Kusi'][$i - 1] }}</td>
                <td>4</td>
                <td><span class="badge bg-{{ ['success', 'danger', 'success', 'success', 'success', 'success'][$i - 1] }}">
                    {{ ['PAID', 'UNPAID', 'PAID', 'PAID', 'PAID', 'PAID'][$i - 1] }}
                </span></td>
                <td>2 Items</td>
                <td><span class="badge bg-{{ ['info', 'success', 'danger', 'success', 'success', 'success'][$i - 1] }}">
                    {{ ['PROCESS', 'DONE', 'CANCEL', 'DONE', 'DONE', 'DONE'][$i - 1] }}
                </span></td>
                <td>
                    <button class="btn btn-sm btn-light"><i class="bi bi-eye"></i></button>
                    <button class="btn btn-sm btn-light"><i class="bi bi-trash"></i></button>
                    <button class="btn btn-sm btn-light"><i class="bi bi-pencil"></i></button>
                </td>
            </tr>
            @endfor
        </tbody>
    </table>
@endsection
